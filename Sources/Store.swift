// CornerClick — Store.swift
// Persistence and import of CornerClick 0.9 preferences.

import AppKit
import Combine

@MainActor
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private static let defaultsKey = "settings.v1"
    static let legacyDomain = "us.vario.greg.CornerClick"

    @Published var settings: Settings {
        didSet {
            guard settings != oldValue else { return }
            save()
        }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.defaultsKey),
           let s = try? JSONDecoder().decode(Settings.self, from: data) {
            settings = s
        } else {
            settings = Settings()
        }
    }

    var isFirstLaunch: Bool { UserDefaults.standard.data(forKey: Self.defaultsKey) == nil }

    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }

    // MARK: Editing helpers

    func layoutKey(forDisplay uuid: String?) -> String {
        settings.perDisplay ? (uuid ?? Settings.allDisplaysKey) : Settings.allDisplaysKey
    }

    func binding(displayKey: String, corner: Corner) -> CornerConfig {
        (settings.layouts[displayKey] ?? CornerLayout())[corner]
    }

    func update(displayKey: String, corner: Corner, _ body: (inout CornerConfig) -> Void) {
        var layout = settings.layouts[displayKey] ?? CornerLayout()
        var cfg = layout[corner]
        body(&cfg)
        layout[corner] = cfg
        settings.layouts[displayKey] = layout
    }

    /// When switching to per-display mode, seed every connected display with the shared layout.
    func setPerDisplay(_ on: Bool) {
        var s = settings
        if on && !s.perDisplay {
            let shared = s.layouts[Settings.allDisplaysKey] ?? CornerLayout()
            for screen in NSScreen.screens {
                if let id = screen.displayUUID, s.layouts[id] == nil { s.layouts[id] = shared }
            }
        } else if !on && s.perDisplay {
            if (s.layouts[Settings.allDisplaysKey] ?? CornerLayout()).isEmpty,
               let main = NSScreen.main?.displayUUID, let l = s.layouts[main] {
                s.layouts[Settings.allDisplaysKey] = l
            }
        }
        s.perDisplay = on
        settings = s
    }

    // MARK: Legacy import (CornerClick 0.9 / us.vario.greg.CornerClick)

    var legacyPreferencesAvailable: Bool {
        UserDefaults.standard.persistentDomain(forName: Self.legacyDomain)?["screens"] != nil
    }

    @discardableResult
    func importLegacyFromDefaults() -> Int {
        guard let dict = UserDefaults.standard.persistentDomain(forName: Self.legacyDomain) else { return 0 }
        return importLegacy(dict)
    }

    /// Import from a `us.vario.greg.CornerClick.plist` file (e.g. copied from an old Mac or a backup).
    func importLegacy(fileURL: URL) throws -> Int {
        let data = try Data(contentsOf: fileURL)
        guard let dict = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let n = importLegacy(dict)
        if n == 0 { throw CocoaError(.fileReadCorruptFile) }
        return n
    }

    /// Returns the number of actions imported.
    func importLegacy(_ dict: [String: Any]) -> Int {
        guard let screens = dict["screens"] as? [String: Any], !screens.isEmpty else { return 0 }
        var s = settings
        var count = 0

        func num(_ v: Any?) -> Double? {
            if let n = v as? NSNumber { return n.doubleValue }
            if let str = v as? String { return Double(str) }
            return nil
        }

        func convert(_ raw: Any) -> CornerLayout {
            var layout = CornerLayout()
            guard let corners = raw as? [Any] else { return layout }
            for (i, c) in corners.prefix(4).enumerated() {
                guard let cd = c as? [String: Any], let corner = Corner(rawValue: i) else { continue }
                var cfg = CornerConfig()
                cfg.enabled = (num(cd["enabled"]) ?? 1) != 0
                for a in (cd["actionList"] as? [[String: Any]]) ?? [] {
                    if let act = convertAction(a) { cfg.actions.append(act); count += 1 }
                }
                layout[corner] = cfg
            }
            return layout
        }

        func convertAction(_ a: [String: Any]) -> CornerAction? {
            let type = Int(num(a["action"]) ?? -1)
            let kind: ActionKind
            var target = ""
            var label = ""
            switch type {
            case 0: kind = .openItem; target = a["chosenFilePath"] as? String ?? ""; label = a["fileLabel"] as? String ?? ""
            case 1: kind = .hideFrontApp
            case 2: kind = .hideOtherApps
            case 3: kind = .openURL; target = a["chosenURL"] as? String ?? ""; label = a["urlDesc"] as? String ?? ""
            case 4: kind = .runAppleScript; target = a["chosenFilePath"] as? String ?? ""; label = a["scriptDesc"] as? String ?? ""
            case 5: kind = .missionControl
            case 6: kind = .appWindows
            case 7: kind = .showDesktop
            case 9: kind = .screenSaver
            default: return nil // 8 = Dashboard, removed from macOS
            }
            var act = CornerAction(kind: kind, target: target, label: label)
            act.modifiers = Modifiers(rawValue: Int(num(a["modifiers"]) ?? 0))
            act.trigger = Trigger(rawValue: Int(num(a["trigger"]) ?? 0)) ?? .click
            act.delayed = (num(a["triggerDelayed"]) ?? 0) != 0
            return act.isValid ? act : nil
        }

        let converted = screens.mapValues(convert).filter { !$0.value.isEmpty }
        guard !converted.isEmpty else { return 0 }

        if converted.count == 1, let only = converted.values.first {
            s.perDisplay = false
            s.layouts[Settings.allDisplaysKey] = only
        } else {
            // Old keys are CGDirectDisplayIDs; map the ones we can see to stable UUIDs.
            s.perDisplay = true
            var byID: [String: String] = [:]
            for screen in NSScreen.screens {
                if let id = screen.displayID, let uuid = screen.displayUUID { byID[String(id)] = uuid }
            }
            var unmatched: [CornerLayout] = []
            for (k, l) in converted.sorted(by: { $0.key < $1.key }) {
                if let uuid = byID[k] { s.layouts[uuid] = l } else { unmatched.append(l) }
            }
            for screen in NSScreen.screens {
                guard let uuid = screen.displayUUID, s.layouts[uuid] == nil, !unmatched.isEmpty else { continue }
                s.layouts[uuid] = unmatched.removeFirst()
            }
            s.layouts[Settings.allDisplaysKey] = converted.values.first
        }

        if let v = num(dict["appEnabled"]) { s.enabled = v != 0 }
        if let v = num(dict["tooltip"]) { s.showHUD = v != 0 }
        let delayed = (num(dict["tooltipDelayed"]) ?? 1) != 0
        s.hudDelay = delayed ? min(2, max(0, num(dict["tooltipDelayTime"]) ?? 1)) : 0
        if let v = num(dict["hoverDelayTime"]) { s.hoverDelay = min(5, max(0.25, v)) }

        settings = s
        return count
    }
}
