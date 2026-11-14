// CornerClick — SelfTest.swift
// Developer self-test: `CC_SELFTEST=/some/dir open -W /Applications/CornerClick.app` (or run the
// binary with the env var). Drives the real corner views with synthesized events and renders the
// HUD and Settings UI to PNGs, without needing Accessibility or Screen Recording permission.

import AppKit
import SwiftUI

@MainActor
enum SelfTest {
    static var outDir: URL? {
        ProcessInfo.processInfo.environment["CC_SELFTEST"].map { URL(fileURLWithPath: $0) }
    }

    static func run(showSettings: @escaping () -> NSWindow?) {
        guard let dir = outDir else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        var report: [String] = []
        @MainActor func note(_ s: String) { report.append(s); NSLog("SELFTEST %@", s) }

        CornerEngine.shared.skipPointerCheck = true
        let panels = CornerEngine.shared.panelsForTesting
        note("panels: \(panels.map { "\($0.corner.title) groups=\($0.groups.count) frame=\(NSStringFromRect($0.frame))" })")

        guard let panel = panels.first, let view = panel.contentView else {
            note("FAIL no panels"); finish(dir, report); return
        }
        let center = NSPoint(x: view.bounds.midX, y: view.bounds.midY)

        // 1. Hover enter → HUD appears
        if let enter = NSEvent.enterExitEvent(with: .mouseEntered, location: center, modifierFlags: [],
                                              timestamp: ProcessInfo.processInfo.systemUptime,
                                              windowNumber: panel.windowNumber, context: nil,
                                              eventNumber: 0, trackingNumber: 0, userData: nil) {
            view.mouseEntered(with: enter)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let hud = NSApp.windows.first(where: { $0 !== panel && $0.level == .popUpMenu && $0.isVisible }) {
                note("HUD visible frame=\(NSStringFromRect(hud.frame))")
                snapshot(hud.contentView, to: dir.appendingPathComponent("hud.png"))
            } else {
                note("FAIL HUD not visible")
            }

            // 2. Click → actions run
            for (type, name) in [(NSEvent.EventType.leftMouseDown, "click"), (.rightMouseDown, "right-click")] {
                if let e = NSEvent.mouseEvent(with: type, location: center, modifierFlags: [],
                                              timestamp: ProcessInfo.processInfo.systemUptime,
                                              windowNumber: panel.windowNumber, context: nil,
                                              eventNumber: 0, clickCount: 1, pressure: 1) {
                    panel.sendEvent(e)
                    note("sent \(name)")
                }
            }

            // 3. Settings UI renders
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                guard let win = showSettings(), let tabs = win.contentViewController as? NSTabViewController else {
                    note("FAIL settings window"); finish(dir, report); return
                }
                var i = 0
                @MainActor func next() {
                    guard i < tabs.tabViewItems.count else {
                        renderEditor(dir)
                        note("settings tabs rendered: \(tabs.tabViewItems.count)")
                        finish(dir, report)
                        return
                    }
                    tabs.selectedTabViewItemIndex = i
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        snapshot(win.contentView?.superview ?? win.contentView,
                                 to: dir.appendingPathComponent("settings-\(i).png"))
                        i += 1
                        next()
                    }
                }
                next()
            }
        }
    }

    private static func renderEditor(_ dir: URL) {
        var a = CornerAction(kind: .openItem, target: "/System/Applications/Calendar.app")
        a.modifiers = [.command, .option]
        let host = NSHostingView(rootView: ActionEditor(original: a, isNew: false, siblings: []) { _ in })
        let w = NSWindow(contentRect: NSRect(origin: .zero, size: host.fittingSize), styleMask: [.titled], backing: .buffered, defer: false)
        w.contentView = host
        w.setFrameOrigin(NSPoint(x: -4000, y: -4000))
        w.orderFrontRegardless()
        host.layoutSubtreeIfNeeded()
        snapshot(host, to: dir.appendingPathComponent("editor.png"))
        w.orderOut(nil)
    }

    static func snapshot(_ view: NSView?, to url: URL) {
        guard let view, let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
        view.cacheDisplay(in: view.bounds, to: rep)
        try? rep.representation(using: .png, properties: [:])?.write(to: url)
    }

    private static func finish(_ dir: URL, _ report: [String]) {
        try? report.joined(separator: "\n").write(to: dir.appendingPathComponent("report.txt"), atomically: true, encoding: .utf8)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { NSApp.terminate(nil) }
    }
}
