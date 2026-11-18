// CornerClick — CornerEngine.swift
// Invisible hot-area panels in each screen corner, hover/click handling and the action HUD.
//
// Same idea as the 2003 original: tiny windows sit in the exact corner pixels. Fitts's law makes
// the corners infinitely large targets, so they behave like four buttons that never move.

import AppKit
import Combine
import os

let log = Logger(subsystem: "io.github.cornerclick.CornerClick", category: "engine")

/// A group of actions sharing the same trigger + modifiers. They run together, in order.
struct ActionGroup: Identifiable, Equatable {
    var actions: [CornerAction]
    var id: String { actions.first?.groupKey ?? UUID().uuidString }
    var first: CornerAction { actions[0] }
    var trigger: Trigger { first.trigger }
    var modifiers: Modifiers { first.modifiers }
    var delayed: Bool { first.trigger == .hover && first.delayed }

    static func groups(for actions: [CornerAction]) -> [ActionGroup] {
        var order: [String] = []
        var map: [String: [CornerAction]] = [:]
        for a in actions where a.isValid {
            if map[a.groupKey] == nil { order.append(a.groupKey) }
            map[a.groupKey, default: []].append(a)
        }
        return order.map { ActionGroup(actions: map[$0]!) }
            .sorted { ($0.trigger.rawValue, $0.modifiers.rawValue, $0.delayed ? 1 : 0) < ($1.trigger.rawValue, $1.modifiers.rawValue, $1.delayed ? 1 : 0) }
    }
}

@MainActor
final class CornerEngine {
    static let shared = CornerEngine()

    private var panels: [String: CornerPanel] = [:]   // "<displayUUID>-<corner>"
    private var cancellables = Set<AnyCancellable>()
    private let hud = HUDController()
    private let glow = CornerGlow()

    // Hover state
    private var active: CornerPanel?
    private var currentMods: Modifiers = []
    private var selectedIndex: Int?
    private var modPoll: Timer?
    private var hoverTimer: Timer?
    private var hudTimer: Timer?
    private var firedHover = false

    private var settings: Settings { SettingsStore.shared.settings }

    var skipPointerCheck = false
    var panelsForTesting: [CornerPanel] { panels.values.sorted { $0.corner.rawValue < $1.corner.rawValue } }

    func start() {
        // dropFirst: the explicit rebuild() below covers launch. The value is passed through
        // because @Published emits in willSet, before `settings` holds the new value.
        SettingsStore.shared.$settings
            .dropFirst()
            .removeDuplicates()
            .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
            .sink { [weak self] s in self?.rebuild(with: s) }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .merge(with: NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification),
                   NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.screensDidWakeNotification))
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.rebuild() }
            .store(in: &cancellables)
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .sink { [weak self] _ in self?.panels.values.forEach { $0.orderFrontRegardless() } }
            .store(in: &cancellables)
        rebuild()
    }

    /// Re-creates or updates corner panels to match settings and connected displays.
    func rebuild(with s: Settings? = nil) {
        let settings = s ?? self.settings
        endHover()
        var wanted = Set<String>()
        if settings.enabled {
            for screen in NSScreen.screens {
                let uuid = screen.displayUUID ?? "screen-\(screen.displayID ?? 0)"
                let layout = settings.layout(forDisplay: uuid)
                for corner in Corner.allCases where Self.isOuterCorner(corner, of: screen) {
                    let cfg = layout[corner]
                    let groups = ActionGroup.groups(for: cfg.actions)
                    guard cfg.enabled, !groups.isEmpty else { continue }
                    let key = "\(uuid)-\(corner.rawValue)"
                    wanted.insert(key)
                    let panel = panels[key] ?? {
                        let p = CornerPanel(corner: corner, engine: self)
                        panels[key] = p
                        return p
                    }()
                    panel.groups = groups
                    panel.screen_ = screen
                    panel.place(size: CGFloat(settings.hotAreaSize), indicator: settings.showIndicators,
                                glass: settings.cornerHighlight == .glass)
                }
            }
        }
        log.info("rebuild: \(wanted.count) corner panel(s)")
        for (key, panel) in panels where !wanted.contains(key) {
            panel.orderOut(nil)
            panels.removeValue(forKey: key)
        }
        // If the pointer is already resting in a corner, no enter event will come; start hovering.
        let mouse = NSEvent.mouseLocation
        if let p = panels.values.first(where: { $0.frame.contains(mouse) }) { mouseEntered(p, runImmediate: false) }
    }

    /// A corner that touches another display is not a Fitts target: the pointer passes through it.
    private static func isOuterCorner(_ c: Corner, of screen: NSScreen) -> Bool {
        let f = screen.frame
        let x = c.isLeft ? f.minX - 1 : f.maxX + 1
        let y = c.isTop ? f.maxY + 1 : f.minY - 1
        let px = c.isLeft ? f.minX : f.maxX - 1
        let py = c.isTop ? f.maxY - 1 : f.minY
        let beyond = [NSPoint(x: x, y: py), NSPoint(x: px, y: y), NSPoint(x: x, y: y)]
        return !NSScreen.screens.contains { other in other !== screen && beyond.contains { other.frame.contains($0) } }
    }

    // MARK: Hover lifecycle

    /// Bumped on every enter/exit so timers from an earlier hover can never act on a newer one.
    private var session = 0

    fileprivate func mouseEntered(_ panel: CornerPanel, runImmediate: Bool = true) {
        log.info("entered \(panel.corner.title, privacy: .public)")
        endHover()
        active = panel
        firedHover = false
        selectedIndex = nil
        currentMods = Modifiers(eventFlags: NSEvent.modifierFlags)
        panel.setHighlighted(true)
        if settings.cornerHighlight == .glass, let screen = panel.screen_ {
            glow.show(corner: panel.corner, screen: screen)
        }
        let token = session

        // NSEvent.modifierFlags reads hardware state without needing Accessibility permission.
        modPoll = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.session == token else { return }
                self.pollModifiers()
            }
        }

        // Immediate hover actions fire right away; delayed ones after the hover delay.
        if runImmediate && runHover(delayedOnly: false, includeDelayed: false) { return }
        scheduleHoverTimer()

        if settings.showHUD {
            hudTimer = Timer.scheduledTimer(withTimeInterval: max(0.01, settings.hudDelay), repeats: false) { [weak self] _ in
                MainActor.assumeIsolated {
                    guard let self, self.session == token else { return }
                    self.showHUD()
                }
            }
        }
    }

    fileprivate func mouseExited(_ panel: CornerPanel) {
        log.info("exited \(panel.corner.title, privacy: .public)")
        guard panel === active else { return }
        endHover()
    }

    private func endHover() {
        session += 1
        modPoll?.invalidate(); modPoll = nil
        hoverTimer?.invalidate(); hoverTimer = nil
        hudTimer?.invalidate(); hudTimer = nil
        active?.setHighlighted(false)
        glow.hide()
        active = nil
        selectedIndex = nil
        hud.hide()
    }

    private func pollModifiers() {
        guard let active else { return }
        // Safety net in case an exit event was missed.
        if !skipPointerCheck && !active.frame.insetBy(dx: -2, dy: -2).contains(NSEvent.mouseLocation) {
            endHover(); return
        }
        let m = Modifiers(eventFlags: NSEvent.modifierFlags)
        guard m != currentMods else { return }
        currentMods = m
        selectedIndex = nil
        // Like the original: changing modifiers re-arms hover actions behind the delay so that
        // pressing keys one by one never fires an intermediate combination.
        firedHover = false
        scheduleHoverTimer(forceAll: true)
        if hud.isVisible { showHUD() }
    }

    private func scheduleHoverTimer(forceAll: Bool = false) {
        hoverTimer?.invalidate()
        guard let active, active.groups.contains(where: { $0.trigger == .hover && $0.modifiers == currentMods }) else { return }
        let token = session
        hoverTimer = Timer.scheduledTimer(withTimeInterval: settings.hoverDelay, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.session == token else { return }
                _ = self.runHover(delayedOnly: !forceAll, includeDelayed: true)
            }
        }
    }

    /// Returns true if something ran.
    private func runHover(delayedOnly: Bool, includeDelayed: Bool) -> Bool {
        guard let active, !firedHover else { return false }
        // Never fire while a mouse button is held: window drags, file drags, tiling gestures.
        guard NSEvent.pressedMouseButtons == 0 else {
            if !delayedOnly || includeDelayed { scheduleHoverTimer(forceAll: !delayedOnly) }
            return false
        }
        let matches = active.groups.filter { g in
            g.trigger == .hover && g.modifiers == currentMods &&
            (g.delayed ? includeDelayed : !delayedOnly)
        }
        guard !matches.isEmpty else { return false }
        log.info("hover fired \(matches.count) group(s)")
        firedHover = true
        hud.flash(matches.map(\.id))
        for g in matches { ActionRunner.run(g.actions) }
        hudTimer?.invalidate()
        hud.hide(after: 0.35)
        return true
    }

    fileprivate func clicked(_ panel: CornerPanel, trigger: Trigger, mods: Modifiers) {
        guard panel === active || active == nil else { return }
        hoverTimer?.invalidate()
        let group: ActionGroup?
        if let i = selectedIndex, panel.groups.indices.contains(i) {
            group = panel.groups[i]
        } else {
            group = panel.groups.first { $0.trigger == trigger && $0.modifiers == mods }
        }
        log.info("click \(trigger.title, privacy: .public) mods=\(mods.rawValue) → \(group?.actions.map(\.displayName).joined(separator: "+") ?? "none", privacy: .public)")
        guard let group else { return }
        hud.flash([group.id])
        ActionRunner.run(group.actions)
        selectedIndex = nil
        hudTimer?.invalidate()
        hud.hide(after: 0.3)
    }

    /// Scroll wheel cycles through the action list; clicking then runs the selected entry.
    fileprivate func scrolled(_ panel: CornerPanel, delta: CGFloat) {
        guard panel === active, !panel.groups.isEmpty, abs(delta) > 0.1 else { return }
        let n = panel.groups.count
        let step = delta > 0 ? -1 : 1
        selectedIndex = ((selectedIndex ?? (step > 0 ? -1 : 0)) + step + n) % n
        hoverTimer?.invalidate()
        hudTimer?.invalidate()
        showHUD()
    }

    private func showHUD() {
        guard let active, let screen = active.screen_ else { return }
        hud.show(groups: active.groups,
                 currentMods: currentMods,
                 selected: selectedIndex,
                 corner: active.corner,
                 screen: screen,
                 hotArea: CGFloat(settings.hotAreaSize),
                 size: settings.hudSize)
    }
}

// MARK: - Corner panel

final class CornerPanel: NSPanel {
    let corner: Corner
    weak var engine: CornerEngine?
    var groups: [ActionGroup] = []
    var screen_: NSScreen?
    private let indicator = CornerIndicatorView()

    init(corner: Corner, engine: CornerEngine) {
        self.corner = corner
        self.engine = engine
        super.init(contentRect: NSRect(x: 0, y: 0, width: 8, height: 8),
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        isFloatingPanel = true
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        // Above the menu bar and the Dock so the exact corner pixel is ours.
        level = .popUpMenu
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        isReleasedWhenClosed = false
        acceptsMouseMovedEvents = true
        // Explicitly accept mouse events so the window server never clicks through transparent pixels.
        ignoresMouseEvents = false
        indicator.corner = corner
        indicator.panel = self
        contentView = indicator
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    func place(size: CGFloat, indicator show: Bool, glass: Bool) {
        guard let screen = screen_ else { return }
        let f = screen.frame
        let s = max(2, size)
        let x = corner.isLeft ? f.minX : f.maxX - s
        let y = corner.isTop ? f.maxY - s : f.minY
        setFrame(NSRect(x: x, y: y, width: s, height: s), display: false)
        indicator.showIdle = show
        indicator.glassHighlight = glass
        indicator.needsDisplay = true
        // AppKit does not reliably call updateTrackingAreas for a borderless panel moved with
        // setFrame, so install the tracking area explicitly (verified on macOS 27).
        indicator.updateTracking()
        orderFrontRegardless()
    }

    func setHighlighted(_ on: Bool) {
        indicator.highlighted = on
        indicator.needsDisplay = true
    }

    fileprivate func entered() { engine?.mouseEntered(self) }
    fileprivate func exited() { engine?.mouseExited(self) }
    fileprivate func click(_ t: Trigger, _ m: Modifiers) { engine?.clicked(self, trigger: t, mods: m) }
    fileprivate func scroll(_ d: CGFloat) { engine?.scrolled(self, delta: d) }
}

/// Draws a subtle quarter-circle in the corner and forwards mouse events.
final class CornerIndicatorView: NSView {
    var corner: Corner = .topLeft
    weak var panel: CornerPanel?
    var showIdle = true
    var highlighted = false
    /// The Liquid Glass highlight (CornerGlow) replaces the accent fill while hovering.
    var glassHighlight = false
    private var area: NSTrackingArea?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    func updateTracking() {
        if let area { removeTrackingArea(area) }
        let a = NSTrackingArea(rect: bounds,
                               options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                               owner: self, userInfo: nil)
        addTrackingArea(a)
        area = a
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        updateTracking()
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        bounds.fill()
        // Window-server click-through ignores fully transparent pixels, so always keep a
        // near-invisible fill to guarantee the corner pixel is hit.
        let lit = highlighted && !glassHighlight
        let alpha: CGFloat = lit ? 0.9 : (showIdle ? 0.28 : 0.012)
        let r = bounds.width
        let center = NSPoint(x: corner.isLeft ? 0 : r, y: corner.isTop ? r : 0)
        let path = NSBezierPath()
        path.move(to: center)
        let start: CGFloat
        switch corner {
        case .topLeft: start = 270
        case .topRight: start = 180
        case .bottomLeft: start = 0
        case .bottomRight: start = 90
        }
        path.appendArc(withCenter: center, radius: r * 1.4, startAngle: start, endAngle: start + 90)
        path.close()
        NSColor.controlAccentColor.withAlphaComponent(alpha).setFill()
        path.fill()
        // Belt and braces with ignoresMouseEvents = false: keep every pixel non-transparent.
        NSColor.black.withAlphaComponent(0.012).setFill()
        bounds.fill(using: .sourceOver)
    }

    override func mouseEntered(with event: NSEvent) { panel?.entered() }
    override func mouseExited(with event: NSEvent) { panel?.exited() }
    override func mouseDown(with event: NSEvent) {
        var mods = Modifiers(eventFlags: event.modifierFlags)
        if mods.contains(.control) && groupsLackControlClick {
            mods.remove(.control)
            panel?.click(.rightClick, mods)
        } else {
            panel?.click(.click, mods)
        }
    }
    override func rightMouseDown(with event: NSEvent) {
        panel?.click(.rightClick, Modifiers(eventFlags: event.modifierFlags))
    }

    private var scrollAccum: CGFloat = 0
    override func scrollWheel(with event: NSEvent) {
        if event.phase == .began || event.phase == .mayBegin { scrollAccum = 0 }
        let threshold: CGFloat = event.hasPreciseScrollingDeltas ? 14 : 0.5
        scrollAccum += event.scrollingDeltaY
        while abs(scrollAccum) >= threshold {
            panel?.scroll(scrollAccum)
            scrollAccum -= scrollAccum > 0 ? threshold : -threshold
            if !event.hasPreciseScrollingDeltas { scrollAccum = 0; break }
        }
    }

    /// ⌃-click acts as a right-click unless the user configured a ⌃ Click action explicitly.
    private var groupsLackControlClick: Bool {
        guard let groups = panel?.groups else { return true }
        return !groups.contains { $0.trigger == .click && $0.modifiers.contains(.control) }
    }
}
