// CornerClick — Model.swift
// Copyright 2003-2010 Greg Schueler, 2026 Jens Nørgaard-Offersen. Apache License 2.0.

import AppKit

// MARK: - Corners

enum Corner: Int, Codable, CaseIterable, Identifiable {
    case topLeft = 0, topRight = 1, bottomLeft = 2, bottomRight = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .topLeft: return "Top Left"
        case .topRight: return "Top Right"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        }
    }

    var isTop: Bool { self == .topLeft || self == .topRight }
    var isLeft: Bool { self == .topLeft || self == .bottomLeft }

    /// Key used by the Dock for the built-in Hot Corners feature.
    var dockHotCornerKey: String {
        switch self {
        case .topLeft: return "wvous-tl-corner"
        case .topRight: return "wvous-tr-corner"
        case .bottomLeft: return "wvous-bl-corner"
        case .bottomRight: return "wvous-br-corner"
        }
    }
}

// MARK: - Modifiers

/// Bit values are identical to CornerClick 0.9 so legacy preferences import 1:1.
struct Modifiers: OptionSet, Codable, Hashable {
    let rawValue: Int
    static let shift    = Modifiers(rawValue: 1 << 0)
    static let option   = Modifiers(rawValue: 1 << 1)
    static let command  = Modifiers(rawValue: 1 << 2)
    static let control  = Modifiers(rawValue: 1 << 3)
    static let function = Modifiers(rawValue: 1 << 4)

    /// Display order follows Apple's HIG: Fn ⌃ ⌥ ⇧ ⌘
    static let ordered: [(Modifiers, String, String)] = [
        (.function, "fn", "Function"),
        (.control, "⌃", "Control"),
        (.option, "⌥", "Option"),
        (.shift, "⇧", "Shift"),
        (.command, "⌘", "Command"),
    ]

    init(rawValue: Int) { self.rawValue = rawValue }

    init(eventFlags f: NSEvent.ModifierFlags) {
        var m: Modifiers = []
        if f.contains(.shift) { m.insert(.shift) }
        if f.contains(.option) { m.insert(.option) }
        if f.contains(.command) { m.insert(.command) }
        if f.contains(.control) { m.insert(.control) }
        if f.contains(.function) { m.insert(.function) }
        self = m
    }

    var symbols: String {
        Modifiers.ordered.filter { contains($0.0) }.map { $0.1 }.joined()
    }
}

// MARK: - Triggers

enum Trigger: Int, Codable, CaseIterable, Identifiable {
    case click = 0, rightClick = 1, hover = 2
    var id: Int { rawValue }
    var title: String {
        switch self {
        case .click: return "Click"
        case .rightClick: return "Right-Click"
        case .hover: return "Hover"
        }
    }
}

// MARK: - Action kinds

enum ActionKind: String, Codable, CaseIterable, Identifiable {
    case openItem
    case openURL
    case hideFrontApp
    case hideOtherApps
    case missionControl
    case appWindows
    case showDesktop
    case showApps
    case screenSaver
    case sleepDisplays
    case lockScreen
    case runShortcut
    case runAppleScript

    var id: String { rawValue }

    var title: String {
        switch self {
        case .openItem: return "Open App, File or Folder"
        case .openURL: return "Open URL"
        case .hideFrontApp: return "Hide Current App"
        case .hideOtherApps: return "Hide Other Apps"
        case .missionControl: return "Mission Control"
        case .appWindows: return "App Exposé"
        case .showDesktop: return "Show Desktop"
        case .showApps: return "Show Apps"
        case .screenSaver: return "Start Screen Saver"
        case .sleepDisplays: return "Put Displays to Sleep"
        case .lockScreen: return "Lock Screen"
        case .runShortcut: return "Run Shortcut"
        case .runAppleScript: return "Run AppleScript"
        }
    }

    var symbol: String {
        switch self {
        case .openItem: return "arrow.up.forward.app"
        case .openURL: return "link"
        case .hideFrontApp: return "eye.slash"
        case .hideOtherApps: return "rectangle.on.rectangle.slash"
        case .missionControl: return "rectangle.3.group"
        case .appWindows: return "macwindow.on.rectangle"
        case .showDesktop: return "menubar.dock.rectangle"
        case .showApps: return "square.grid.3x3"
        case .screenSaver: return "sparkles.tv"
        case .sleepDisplays: return "moon.zzz"
        case .lockScreen: return "lock"
        case .runShortcut: return "square.2.layers.3d"
        case .runAppleScript: return "applescript"
        }
    }

    /// Whether the action needs a `target` (path, URL or shortcut name).
    var needsTarget: Bool {
        switch self {
        case .openItem, .openURL, .runShortcut, .runAppleScript: return true
        default: return false
        }
    }

    static let groups: [(String, [ActionKind])] = [
        ("Open", [.openItem, .openURL]),
        ("Apps & Windows", [.hideFrontApp, .hideOtherApps, .missionControl, .appWindows, .showDesktop, .showApps]),
        ("System", [.screenSaver, .sleepDisplays, .lockScreen]),
        ("Automation", [.runShortcut, .runAppleScript]),
    ]
}

// MARK: - Action

struct CornerAction: Codable, Identifiable, Hashable {
    var id = UUID()
    var kind: ActionKind
    /// File path, URL string, or Shortcut name depending on `kind`.
    var target: String = ""
    /// Optional user-provided label shown in the action list.
    var label: String = ""
    var trigger: Trigger = .click
    var modifiers: Modifiers = []
    /// For hover triggers: wait for the hover delay before firing.
    var delayed: Bool = false

    var isValid: Bool {
        !kind.needsTarget || !target.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var displayName: String {
        if !label.isEmpty { return label }
        switch kind {
        case .openItem:
            let name = (target as NSString).lastPathComponent
            if name.isEmpty { return kind.title }
            return name.hasSuffix(".app") ? (name as NSString).deletingPathExtension : name
        case .openURL:
            if let u = URL(string: target), let host = u.host { return host }
            return target.isEmpty ? kind.title : target
        case .runAppleScript:
            let name = ((target as NSString).lastPathComponent as NSString).deletingPathExtension
            return name.isEmpty ? kind.title : name
        case .runShortcut:
            return target.isEmpty ? kind.title : target
        default:
            return kind.title
        }
    }

    /// e.g. "⌥⌘ Right-Click" or "Delayed Hover"
    var triggerDescription: String {
        var t = trigger.title
        if trigger == .hover && delayed { t = "Delayed Hover" }
        let m = modifiers.symbols
        return m.isEmpty ? t : "\(m) \(t)"
    }

    /// Actions with identical trigger + modifiers run together as a combo.
    var groupKey: String { "\(trigger.rawValue)-\(modifiers.rawValue)-\(trigger == .hover && delayed)" }
}

// MARK: - Corner configuration

struct CornerConfig: Codable, Hashable {
    var enabled: Bool = true
    var actions: [CornerAction] = []
}

struct CornerLayout: Codable, Hashable {
    var corners: [CornerConfig] = Array(repeating: CornerConfig(), count: 4)

    subscript(c: Corner) -> CornerConfig {
        get { corners.indices.contains(c.rawValue) ? corners[c.rawValue] : CornerConfig() }
        set {
            while corners.count < 4 { corners.append(CornerConfig()) }
            corners[c.rawValue] = newValue
        }
    }

    var isEmpty: Bool { corners.allSatisfy { $0.actions.isEmpty } }
}

// MARK: - Settings

enum HUDSize: Int, Codable, CaseIterable, Identifiable {
    case small, medium, large
    var id: Int { rawValue }
    var title: String { ["Small", "Medium", "Large"][rawValue] }
    var iconSize: CGFloat { [18, 24, 32][rawValue] }
    var fontSize: CGFloat { [12, 13, 15][rawValue] }
}

struct Settings: Codable, Equatable {
    static let allDisplaysKey = "all"

    var enabled = true
    var perDisplay = false
    /// Keyed by display UUID, or `allDisplaysKey` when `perDisplay` is false.
    var layouts: [String: CornerLayout] = [:]

    var showHUD = true
    var hudDelay: Double = 0.4
    var hudSize: HUDSize = .medium
    var hoverDelay: Double = 1.5
    var showIndicators = true
    var hotAreaSize: Double = 8
    var showInMenuBar = true

    func layout(forDisplay uuid: String?) -> CornerLayout {
        if perDisplay, let uuid { return layouts[uuid] ?? layouts[Settings.allDisplaysKey] ?? CornerLayout() }
        return layouts[Settings.allDisplaysKey] ?? CornerLayout()
    }

    // Tolerant decoding so future/older versions never wipe user data.
    init() {}
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = Settings()
        enabled = (try? c.decode(Bool.self, forKey: .enabled)) ?? d.enabled
        perDisplay = (try? c.decode(Bool.self, forKey: .perDisplay)) ?? d.perDisplay
        layouts = (try? c.decode([String: CornerLayout].self, forKey: .layouts)) ?? d.layouts
        showHUD = (try? c.decode(Bool.self, forKey: .showHUD)) ?? d.showHUD
        hudDelay = (try? c.decode(Double.self, forKey: .hudDelay)) ?? d.hudDelay
        hudSize = (try? c.decode(HUDSize.self, forKey: .hudSize)) ?? d.hudSize
        hoverDelay = (try? c.decode(Double.self, forKey: .hoverDelay)) ?? d.hoverDelay
        showIndicators = (try? c.decode(Bool.self, forKey: .showIndicators)) ?? d.showIndicators
        hotAreaSize = (try? c.decode(Double.self, forKey: .hotAreaSize)) ?? d.hotAreaSize
        showInMenuBar = (try? c.decode(Bool.self, forKey: .showInMenuBar)) ?? d.showInMenuBar
    }
}

// MARK: - Display helpers

extension NSScreen {
    var displayID: CGDirectDisplayID? {
        (deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber)?.uint32Value
    }

    /// Stable identifier that survives reboots and re-plugging (unlike the display ID).
    var displayUUID: String? {
        guard let id = displayID,
              let uuid = CGDisplayCreateUUIDFromDisplayID(id)?.takeRetainedValue() else { return nil }
        return CFUUIDCreateString(nil, uuid) as String
    }
}
