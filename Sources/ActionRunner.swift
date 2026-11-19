// CornerClick — ActionRunner.swift
// Performs corner actions using modern, permission-free APIs where possible.

import AppKit
import os

@MainActor
enum ActionRunner {

    static func run(_ actions: [CornerAction]) {
        for a in actions where a.isValid { run(a) }
    }

    static func run(_ a: CornerAction) {
        switch a.kind {
        case .openItem:
            let url = URL(fileURLWithPath: (a.target as NSString).expandingTildeInPath)
            if url.pathExtension == "app" {
                let cfg = NSWorkspace.OpenConfiguration()
                cfg.activates = true
                NSWorkspace.shared.openApplication(at: url, configuration: cfg) { _, err in
                    if let err {
                        Task { @MainActor in report("Couldn’t open \(url.lastPathComponent)", err.localizedDescription) }
                    }
                }
            } else if !NSWorkspace.shared.open(url) {
                report("Couldn’t open \(url.lastPathComponent)", "The item may have been moved or deleted.")
            }

        case .openURL:
            var s = a.target.trimmingCharacters(in: .whitespaces)
            if URL(string: s)?.scheme == nil { s = "https://" + s }
            if let url = URL(string: s) { NSWorkspace.shared.open(url) }

        case .hideFrontApp:
            // hide() returns false when the app refuses or cannot be hidden. That result used to
            // be discarded, so a refusal looked identical to the action never running at all.
            let frontmost = NSWorkspace.shared.frontmostApplication
            guard let app = frontApp() else {
                log.info("hide skipped: frontmost is \(frontmost?.bundleIdentifier ?? "nil", privacy: .public), which is CornerClick itself")
                return
            }
            let hidden = app.hide()
            log.info("hide \(app.bundleIdentifier ?? "nil", privacy: .public) pid=\(app.processIdentifier) policy=\(app.activationPolicy.rawValue) active=\(app.isActive) alreadyHidden=\(app.isHidden) → \(hidden)")

        case .hideOtherApps:
            let front = frontApp()
            for app in NSWorkspace.shared.runningApplications
            where app.activationPolicy == .regular && app != front && app != .current && !app.isHidden {
                app.hide()
            }

        case .missionControl:
            dock("com.apple.expose.awake", fallbackArg: nil)
        case .appWindows:
            dock("com.apple.expose.front.awake", fallbackArg: "2")
        case .showDesktop:
            dock("com.apple.showdesktop.awake", fallbackArg: "1")

        case .showApps:
            let candidates = ["/System/Applications/Apps.app", "/System/Applications/Launchpad.app"]
            if let path = candidates.first(where: { FileManager.default.fileExists(atPath: $0) }) {
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
            } else {
                dock("com.apple.launchpad.toggle", fallbackArg: nil)
            }

        case .screenSaver:
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/CoreServices/ScreenSaverEngine.app"))

        case .sleepDisplays:
            launch("/usr/bin/pmset", ["displaysleepnow"])

        case .lockScreen:
            if !lockScreen() { launch("/usr/bin/pmset", ["displaysleepnow"]) }

        case .runShortcut:
            launch("/usr/bin/shortcuts", ["run", a.target])

        case .runAppleScript:
            // Out of process so a slow script (or its first-run permission prompt) never blocks corners.
            let path = (a.target as NSString).expandingTildeInPath
            guard FileManager.default.fileExists(atPath: path) else {
                report("AppleScript not found", path); return
            }
            launch("/usr/bin/osascript", [path])
        }
    }

    /// The app the user is working in. CornerClick never activates itself when a corner is
    /// clicked, so this is the real frontmost app.
    private static func frontApp() -> NSRunningApplication? {
        let f = NSWorkspace.shared.frontmostApplication
        return f == .current ? nil : f
    }

    // MARK: Dock / Mission Control

    private typealias CoreDockSendNotificationFn = @convention(c) (CFString, Int32) -> Void

    private static let coreDockSend: CoreDockSendNotificationFn? = {
        let handle = dlopen("/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices", RTLD_LAZY)
        guard let sym = dlsym(handle ?? dlopen(nil, RTLD_LAZY), "CoreDockSendNotification") else { return nil }
        return unsafeBitCast(sym, to: CoreDockSendNotificationFn.self)
    }()

    private static func dock(_ notification: String, fallbackArg: String?) {
        if let send = coreDockSend {
            send(notification as CFString, 0)
            return
        }
        let mc = "/System/Applications/Mission Control.app/Contents/MacOS/Mission Control"
        launch(mc, fallbackArg.map { [$0] } ?? [])
    }

    // MARK: Lock screen

    private typealias SACLockFn = @convention(c) () -> Int32

    private static func lockScreen() -> Bool {
        guard let h = dlopen("/System/Library/PrivateFrameworks/login.framework/Versions/Current/login", RTLD_LAZY),
              let sym = dlsym(h, "SACLockScreenImmediate") else { return false }
        _ = unsafeBitCast(sym, to: SACLockFn.self)()
        return true
    }

    // MARK: Helpers

    private static func launch(_ path: String, _ args: [String]) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        p.standardOutput = FileHandle.nullDevice
        let errPipe = Pipe()
        p.standardError = errPipe
        p.terminationHandler = { proc in
            guard proc.terminationStatus != 0 else { return }
            let msg = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            Task { @MainActor in report("“\(([path] + args).joined(separator: " "))” failed", msg) }
        }
        do { try p.run() } catch { report("Couldn’t run \(path)", error.localizedDescription) }
    }

    static func report(_ title: String, _ detail: String) {
        NSLog("CornerClick: %@ — %@", title, detail)
        NSSound.beep()
        ErrorBanner.show(title: title, detail: detail)
    }
}
