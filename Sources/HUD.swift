// CornerClick — HUD.swift
// The floating action list shown when pointing at a corner (Liquid Glass on macOS 26+).

import AppKit
import SwiftUI

@MainActor
final class HUDModel: ObservableObject {
    @Published var groups: [ActionGroup] = []
    @Published var currentMods: Modifiers = []
    @Published var selected: Int?
    @Published var flashed: Set<String> = []
    @Published var size: HUDSize = .medium
    @Published var corner: Corner = .topLeft
}

@MainActor
final class HUDController {
    private let model = HUDModel()
    private lazy var panel: NSPanel = makePanel()
    private lazy var host = NSHostingView(rootView: HUDView(model: model))
    private var hideWork: DispatchWorkItem?

    var isVisible: Bool { panel.isVisible && panel.alphaValue > 0.01 }

    private func makePanel() -> NSPanel {
        let p = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.level = .popUpMenu
        p.ignoresMouseEvents = true
        p.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        p.hidesOnDeactivate = false
        p.isReleasedWhenClosed = false
        p.contentView = host
        return p
    }

    func show(groups: [ActionGroup], currentMods: Modifiers, selected: Int?, corner: Corner,
              screen: NSScreen, hotArea: CGFloat, size: HUDSize) {
        hideWork?.cancel()
        model.groups = groups
        model.currentMods = currentMods
        model.selected = selected
        model.size = size
        model.corner = corner
        model.flashed = []

        host.layoutSubtreeIfNeeded()
        let fit = host.fittingSize
        let f = screen.frame, v = screen.visibleFrame
        let gap: CGFloat = 6
        let x = corner.isLeft
            ? max(f.minX + hotArea + gap, v.minX + gap)
            : min(f.maxX - hotArea - gap, v.maxX - gap) - fit.width
        let y = corner.isTop
            ? min(f.maxY - hotArea - gap, v.maxY - gap) - fit.height
            : max(f.minY + hotArea + gap, v.minY + gap)
        panel.setFrame(NSRect(x: x, y: y, width: fit.width, height: fit.height), display: true)

        if !panel.isVisible || panel.alphaValue < 1 {
            if !panel.isVisible { panel.alphaValue = 0 }
            panel.orderFrontRegardless()
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.12
                panel.animator().alphaValue = 1
            }
        }
    }

    func flash(_ ids: [String]) {
        guard isVisible else { return }
        withAnimation(.easeOut(duration: 0.12)) { model.flashed = Set(ids) }
    }

    func hide(after delay: TimeInterval = 0) {
        hideWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.panel.isVisible else { return }
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.18
                self.panel.animator().alphaValue = 0
            }, completionHandler: {
                Task { @MainActor in
                    if self.panel.alphaValue < 0.01 { self.panel.orderOut(nil) }
                }
            })
        }
        hideWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }
}

// MARK: - SwiftUI

struct HUDView: View {
    @ObservedObject var model: HUDModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(model.groups.enumerated()), id: \.element.id) { i, g in
                HUDRow(group: g,
                       size: model.size,
                       state: state(for: g, index: i))
            }
            if model.groups.count > 1 {
                Text("Scroll to choose · Click to run")
                    .font(.system(size: model.size.fontSize - 2))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 8)
                    .padding(.top, 3)
                    .frame(maxWidth: .infinity, alignment: model.corner.isLeft ? .leading : .trailing)
            }
        }
        .padding(6)
        .frame(minWidth: 220, maxWidth: 420, alignment: .leading)
        .fixedSize()
        .modifier(GlassBackground(cornerRadius: 16))
        .padding(10) // room for the shadow
    }

    private func state(for g: ActionGroup, index i: Int) -> HUDRow.State {
        if model.flashed.contains(g.id) { return .fired }
        if let s = model.selected { return s == i ? .selected : .dimmed }
        return g.modifiers == model.currentMods ? .match : .dimmed
    }
}

struct HUDRow: View {
    enum State { case match, dimmed, selected, fired }
    let group: ActionGroup
    let size: HUDSize
    let state: State

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                ForEach(Array(group.actions.prefix(3).enumerated().reversed()), id: \.offset) { i, a in
                    ActionIcon(action: a, size: size.iconSize)
                        .offset(x: CGFloat(i) * size.iconSize * 0.28)
                }
            }
            .frame(width: size.iconSize + CGFloat(min(group.actions.count, 3) - 1) * size.iconSize * 0.28,
                   alignment: .leading)

            Text(group.actions.map(\.displayName).joined(separator: " + "))
                .font(.system(size: size.fontSize, weight: .medium))
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer(minLength: 16)

            Text(group.first.triggerDescription)
                .font(.system(size: size.fontSize - 1, weight: .regular).monospacedDigit())
                .foregroundStyle(highlighted ? AnyShapeStyle(.white.opacity(0.85)) : AnyShapeStyle(.secondary))
        }
        .foregroundStyle(highlighted ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(highlighted ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.clear))
        }
        .opacity(state == .dimmed ? 0.45 : 1)
        .scaleEffect(state == .fired ? 0.97 : 1)
    }

    private var highlighted: Bool { state == .selected || state == .fired }
}

struct ActionIcon: View {
    let action: CornerAction
    let size: CGFloat

    var body: some View {
        if let img = IconCache.icon(for: action) {
            Image(nsImage: img)
                .resizable()
                .interpolation(.high)
                .frame(width: size, height: size)
        } else {
            Image(systemName: action.kind.symbol)
                .font(.system(size: size * 0.5, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .fill(LinearGradient(colors: [tint.opacity(0.85), tint],
                                             startPoint: .top, endPoint: .bottom))
                )
        }
    }

    private var tint: Color {
        switch action.kind {
        case .openURL: return .blue
        case .hideFrontApp, .hideOtherApps: return .gray
        case .missionControl, .appWindows, .showDesktop, .showApps: return .indigo
        case .screenSaver, .sleepDisplays, .lockScreen: return .purple
        case .runShortcut: return .pink
        default: return .accentColor
        }
    }
}

@MainActor
enum IconCache {
    private static var cache: [String: NSImage] = [:]

    static func icon(for a: CornerAction) -> NSImage? {
        guard a.kind == .openItem || a.kind == .runAppleScript, !a.target.isEmpty else { return nil }
        let path = (a.target as NSString).expandingTildeInPath
        if let i = cache[path] { return i }
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        let i = NSWorkspace.shared.icon(forFile: path)
        cache[path] = i
        return i
    }
}

/// Liquid Glass on macOS 26+, material fallback before that.
struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if #available(macOS 26.0, *) {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            content
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(.white.opacity(0.15)))
                .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
        }
    }
}

// MARK: - Error banner

@MainActor
enum ErrorBanner {
    private static var panel: NSPanel?
    private static var work: DispatchWorkItem?

    static func show(title: String, detail: String) {
        let view = HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                if !detail.isEmpty {
                    Text(detail.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.callout).foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: 380, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .modifier(GlassBackground(cornerRadius: 18))
        .padding(10)

        let host = NSHostingView(rootView: view)
        let p = panel ?? {
            let p = NSPanel(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: true)
            p.isOpaque = false; p.backgroundColor = .clear; p.hasShadow = false
            p.level = .statusBar; p.ignoresMouseEvents = true
            p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            p.isReleasedWhenClosed = false
            panel = p
            return p
        }()
        p.contentView = host
        let size = host.fittingSize
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let v = screen.visibleFrame
        p.setFrame(NSRect(x: v.midX - size.width / 2, y: v.maxY - size.height - 8, width: size.width, height: size.height),
                   display: true)
        p.alphaValue = 1
        p.orderFrontRegardless()
        work?.cancel()
        let w = DispatchWorkItem {
            NSAnimationContext.runAnimationGroup({ $0.duration = 0.3; p.animator().alphaValue = 0 },
                                                 completionHandler: { Task { @MainActor in p.orderOut(nil) } })
        }
        work = w
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: w)
    }
}
