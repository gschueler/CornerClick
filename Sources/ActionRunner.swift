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
            hideFrontApp()

        case .hideOtherApps:
            let front = frontApp()
            for app in NSWorkspace.shared.runningApplications
            where app.activationPolicy == .regular && app != front && app != .current && !app.isHidden {
                // Recorded, not judged: a false here does not mean the app stayed visible.
                if !app.hide() {
                    log.info("hide-others \(app.bundleIdentifier ?? "nil", privacy: .public) sent=false")
                }
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

    /// Hides the frontmost app.
    ///
    /// `NSRunningApplication.hide()`'s result cannot be trusted, for two separate reasons found
    /// while chasing a report that this action did nothing for Google Chrome.
    ///
    /// Apple documents the Bool as whether the request was successfully *sent*, not whether the
    /// app hid — and on macOS 27 it comes back false even when the app hides perfectly well,
    /// observed here with Chrome. Showing the user anything based on it would mean an error
    /// banner on every successful hide.
    ///
    /// The actual failure in that report was LaunchServices parentage, not the app: Chrome had
    /// been launched at login by a Chrome App shim and was registered as a child ASN of it.
    /// While it sat in that slot no third-party caller could hide it — not this app, not a plain
    /// osascript process, not `hideOtherApplications()` — though ⌘H and the Dock's own Hide
    /// still worked, as neither goes through LaunchServices. Relaunching Chrome with ordinary
    /// parentage fixed it with no code change. Nothing here is Chrome- or Chromium-specific.
    ///
    /// So: ask, then confirm against `isHidden`, and only speak up if the app really is still
    /// on screen. The original one-liner discarded the result entirely, which is why this looked
    /// like a corner that never fired rather than a hide that never happened.
    private static func hideFrontApp() {
        guard let app = frontApp() else {
            let frontmost = NSWorkspace.shared.frontmostApplication
            log.info("hide skipped: frontmost is \(frontmost?.bundleIdentifier ?? "nil", privacy: .public), which is CornerClick itself")
            return
        }
        let id = app.bundleIdentifier ?? "nil"
        let pid = app.processIdentifier
        let name = app.localizedName ?? id

        // Ask twice, the second time on a freshly resolved handle in case the first is stale.
        let sent = app.hide() || NSRunningApplication(processIdentifier: pid)?.hide() == true
        log.info("hide \(id, privacy: .public) pid=\(pid) sent=\(sent)")

        // Confirm on BOTH paths. hide() reports only that the request went out, and it is
        // unreliable in both directions on recent macOS: an app that hides and then puts itself
        // straight back would otherwise be logged as a success and never looked at again.
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(600))
            guard let live = NSRunningApplication(processIdentifier: pid), !live.isTerminated else { return }
            if live.isHidden {
                log.info("hide \(id, privacy: .public) confirmed hidden")
                return
            }
            log.error("hide \(id, privacy: .public) did not take effect (sent=\(sent))")
            // Deliberately not branching this message on `sent`. On recent macOS that Bool
            // comes back false for apps that hide perfectly well, so it cannot carry a reason —
            // only the isHidden check above is worth anything, and it says the same either way.
            report("Couldn’t hide \(name)", "\(name) didn’t respond to the hide request. Try ⌘H in the app itself.")
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
