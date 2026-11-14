// CornerClick — main.swift
// App lifecycle, menu bar extra and the Settings window.

import AppKit
import Combine
import ServiceManagement
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private let store = SettingsStore.shared

    func applicationDidFinishLaunching(_ note: Notification) {
        NSApp.mainMenu = buildMainMenu()

        let firstLaunch = store.isFirstLaunch
        if firstLaunch {
            if store.legacyPreferencesAvailable { store.importLegacyFromDefaults() }
            store.save()
            // CornerClick is meant to always be running; register as a login item once.
            try? SMAppService.mainApp.register()
        }

        CornerEngine.shared.start()

        store.$settings.map(\.showInMenuBar).removeDuplicates()
            .sink { [weak self] show in self?.updateStatusItem(show) }
            .store(in: &cancellables)
        store.$settings.map(\.enabled).removeDuplicates()
            .sink { [weak self] _ in self?.refreshStatusIcon() }
            .store(in: &cancellables)

        if SelfTest.outDir != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                SelfTest.run { [weak self] in self?.showSettings(nil); return self?.settingsWindow }
            }
        } else if firstLaunch {
            showSettings(nil)
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings(nil)
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }

    // MARK: Menu bar extra

    private func updateStatusItem(_ show: Bool) {
        if show, statusItem == nil {
            let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            item.behavior = .removalAllowed
            let menu = NSMenu()
            menu.delegate = self
            item.menu = menu
            statusItem = item
            refreshStatusIcon()
        } else if !show, let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
            statusItem = nil
        }
    }

    private func refreshStatusIcon() {
        guard let button = statusItem?.button else { return }
        button.image = StatusIcon.image(enabled: store.settings.enabled)
        button.toolTip = store.settings.enabled ? "CornerClick" : "CornerClick (Off)"
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let toggle = NSMenuItem(title: "CornerClick", action: #selector(toggleEnabled(_:)), keyEquivalent: "")
        toggle.state = store.settings.enabled ? .on : .off
        toggle.target = self
        menu.addItem(toggle)
        menu.addItem(.separator())
        let settings = NSMenuItem(title: "Settings…", action: #selector(showSettings(_:)), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)
        let about = NSMenuItem(title: "About CornerClick", action: #selector(showAbout(_:)), keyEquivalent: "")
        about.target = self
        menu.addItem(about)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit CornerClick", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    @objc private func toggleEnabled(_ sender: Any?) {
        store.settings.enabled.toggle()
    }

    // MARK: Settings window

    private var tabController: NSTabViewController?

    @objc func showSettings(_ sender: Any?) {
        if settingsWindow == nil { buildSettingsWindow() }
        NSApp.setActivationPolicy(.regular)
        NSApp.activate()
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc func showAbout(_ sender: Any?) {
        showSettings(sender)
        tabController?.selectedTabViewItemIndex = 2
    }

    private func buildSettingsWindow() {
        let tabs = NSTabViewController()
        tabs.tabStyle = .toolbar
        tabs.transitionOptions = [.crossfade, .allowUserInteraction]
        tabs.canPropagateSelectedChildViewControllerTitle = true

        func add<V: View>(_ title: String, _ symbol: String, _ view: V) {
            let host = NSHostingController(rootView: view)
            host.sizingOptions = [.preferredContentSize]
            host.title = title
            let item = NSTabViewItem(viewController: host)
            item.label = title
            item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: title)
            tabs.addTabViewItem(item)
        }
        add("Corners", "rectangle.dashed", CornersView())
        add("General", "gearshape", GeneralView())
        add("About", "info.circle", AboutView())

        let window = NSWindow(contentViewController: tabs)
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.toolbarStyle = .preference
        window.title = "Corners"
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName("CornerClickSettings")
        window.center()
        settingsWindow = window
        tabController = tabs
    }

    func windowWillClose(_ notification: Notification) {
        guard (notification.object as? NSWindow) === settingsWindow else { return }
        // Back to a menu-bar-only app once Settings is closed.
        DispatchQueue.main.async { NSApp.setActivationPolicy(.accessory) }
    }

    // MARK: Main menu (for ⌘W, ⌘Q, copy/paste in text fields)

    private func buildMainMenu() -> NSMenu {
        let main = NSMenu()

        let appItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About CornerClick", action: #selector(showAbout(_:)), keyEquivalent: "").target = self
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Settings…", action: #selector(showSettings(_:)), keyEquivalent: ",").target = self
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Hide CornerClick", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        appMenu.addItem(withTitle: "Quit CornerClick", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu
        main.addItem(appItem)

        let editItem = NSMenuItem()
        let edit = NSMenu(title: "Edit")
        edit.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        edit.addItem(withTitle: "Redo", action: Selector(("redo:")), keyEquivalent: "Z")
        edit.addItem(.separator())
        edit.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        edit.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        edit.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        edit.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = edit
        main.addItem(editItem)

        let winItem = NSMenuItem()
        let win = NSMenu(title: "Window")
        win.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        win.addItem(withTitle: "Minimize", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        winItem.submenu = win
        main.addItem(winItem)
        NSApp.windowsMenu = win
        return main
    }
}

// MARK: - Menu bar icon

enum StatusIcon {
    /// A display outline with the top-left corner lit — drawn as a template image.
    static func image(enabled: Bool) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let img = NSImage(size: size, flipped: false) { _ in
            let r = NSRect(x: 2, y: 3.5, width: 14, height: 11)
            let outline = NSBezierPath(roundedRect: r, xRadius: 2.5, yRadius: 2.5)
            outline.lineWidth = 1.4
            NSColor.black.setStroke()
            outline.stroke()

            NSColor.black.setFill()
            let corner = NSBezierPath()
            corner.move(to: NSPoint(x: r.minX, y: r.maxY - 6.5))
            corner.line(to: NSPoint(x: r.minX, y: r.maxY - 2.5))
            corner.appendArc(from: NSPoint(x: r.minX, y: r.maxY), to: NSPoint(x: r.minX + 2.5, y: r.maxY), radius: 2.5)
            corner.line(to: NSPoint(x: r.minX + 6.5, y: r.maxY))
            corner.appendArc(withCenter: NSPoint(x: r.minX, y: r.maxY), radius: 6.5, startAngle: 0, endAngle: 270, clockwise: true)
            corner.close()
            corner.fill()

            if !enabled {
                let slash = NSBezierPath()
                slash.move(to: NSPoint(x: 3, y: 1.5))
                slash.line(to: NSPoint(x: 16, y: 16.5))
                slash.lineWidth = 1.6
                slash.stroke()
            }
            return true
        }
        img.isTemplate = true
        img.accessibilityDescription = enabled ? "CornerClick" : "CornerClick (Off)"
        return img
    }
}

// MARK: - Entry point

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    withExtendedLifetime(delegate) { app.run() }
}
