// CornerClick — SettingsView.swift
// SwiftUI settings: Corners, General, About.

import AppKit
import Combine
import ServiceManagement
import SwiftUI
import UniformTypeIdentifiers

/// Every Settings tab lays out at this width, so switching tabs only changes the window's
/// height. Corners needs the most room, so it sets the width for all three.
let settingsTabWidth: CGFloat = 640

// MARK: - Corners tab

struct CornersView: View {
    @ObservedObject private var store = SettingsStore.shared
    @State private var corner: Corner = .topLeft
    @State private var displayUUID: String? = NSScreen.main?.displayUUID
    @State private var selection = Set<CornerAction.ID>()
    @State private var editing: EditRequest?
    @State private var hotCorners = SystemHotCorners.read()
    @State private var screens = NSScreen.screens


    init() {
        // Start on the first corner that has actions.
        let store = SettingsStore.shared
        let layout = store.settings.layouts[store.layoutKey(forDisplay: NSScreen.main?.displayUUID)] ?? CornerLayout()
        _corner = State(initialValue: Corner.allCases.first { !layout[$0].actions.isEmpty } ?? .topLeft)
    }

    private var displayKey: String { store.layoutKey(forDisplay: displayUUID) }
    private var config: CornerConfig { store.binding(displayKey: displayKey, corner: corner) }
    private var layout: CornerLayout { store.settings.layouts[displayKey] ?? CornerLayout() }
    private var selectedScreen: NSScreen? {
        screens.first { $0.displayUUID == displayUUID } ?? NSScreen.main
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if !store.settings.enabled {
                Banner(symbol: "pause.circle.fill", tint: .orange,
                       text: "CornerClick is turned off.",
                       button: "Turn On") { store.settings.enabled = true }
            }
            if let conflict = hotCorners[corner], !config.actions.isEmpty {
                Banner(symbol: "exclamationmark.triangle.fill", tint: .yellow,
                       text: "The macOS Hot Corner “\(conflict)” is also assigned to this corner.",
                       button: "Hot Corners…") { SystemHotCorners.openSettings() }
            }

            displayBar

            ScreenPreview(screen: selectedScreen, layout: layout, selected: $corner, hotCorners: hotCorners)
                .frame(height: 210)
                .frame(maxWidth: .infinity)

            cornerSection
        }
        .padding(20)
        .frame(width: settingsTabWidth, height: 640, alignment: .top)
        .sheet(item: $editing) { req in
            ActionEditor(original: req.action, isNew: req.isNew, siblings: config.actions) { saved in
                store.update(displayKey: displayKey, corner: corner) { cfg in
                    if let i = cfg.actions.firstIndex(where: { $0.id == saved.id }) {
                        cfg.actions[i] = saved
                    } else {
                        cfg.actions.append(saved)
                    }
                }
                selection = [saved.id]
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)) { _ in
            screens = NSScreen.screens
            if !screens.contains(where: { $0.displayUUID == displayUUID }) { displayUUID = NSScreen.main?.displayUUID }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            hotCorners = SystemHotCorners.read()
        }
        .onChange(of: corner) { _, _ in selection = [] }
        .onChange(of: displayKey) { _, _ in selection = [] }
    }

    @ViewBuilder private var displayBar: some View {
        if screens.count > 1 || store.settings.perDisplay {
            HStack {
                if store.settings.perDisplay {
                    Picker("Display", selection: $displayUUID) {
                        ForEach(screens, id: \.displayUUID) { s in
                            Text(s.localizedName).tag(s.displayUUID)
                        }
                    }
                    .fixedSize()
                } else {
                    Label("Same corners on all displays", systemImage: "display.2")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("Separate corners for each display", isOn: Binding(
                    get: { store.settings.perDisplay },
                    set: { store.setPerDisplay($0) }))
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
        }
    }

    private var cornerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(corner.title) Corner").font(.headline)
                Spacer()
                Toggle("Enabled", isOn: Binding(
                    get: { config.enabled },
                    set: { v in store.update(displayKey: displayKey, corner: corner) { $0.enabled = v } }))
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .help("Turn this corner on or off without deleting its actions")
            }

            VStack(spacing: 0) {
                if config.actions.isEmpty {
                    emptyState
                } else {
                    List(selection: $selection) {
                        ForEach(config.actions) { a in
                            ActionRow(action: a, combo: comboCount(a))
                                .tag(a.id)
                        }
                        .onMove { from, to in
                            store.update(displayKey: displayKey, corner: corner) { $0.actions.move(fromOffsets: from, toOffset: to) }
                        }
                    }
                    .listStyle(.inset)
                    .alternatingRowBackgrounds()
                    .contextMenu(forSelectionType: CornerAction.ID.self) { ids in
                        if ids.count == 1, let id = ids.first, let a = action(id) {
                            Button("Edit…") { editing = EditRequest(action: a, isNew: false) }
                            Button("Duplicate") { duplicate(a) }
                            Divider()
                        }
                        if !ids.isEmpty {
                            Button("Delete", role: .destructive) { delete(ids) }
                        }
                    } primaryAction: { ids in
                        if let id = ids.first, let a = action(id) { editing = EditRequest(action: a, isNew: false) }
                    }
                    .onDeleteCommand { delete(selection) }
                }
                Divider()
                bottomBar
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Color(nsColor: .separatorColor)))
            .frame(minHeight: 200)
            .opacity(config.enabled ? 1 : 0.6)

            Text("Actions with the same trigger and modifier keys run together, top to bottom. Drag to reorder.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "cursorarrow.rays")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(.secondary)
            Text("No Actions").font(.headline)
            Text("Add an action to run when you click or hover over the \(corner.title.lowercased()) corner.")
                .font(.callout).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Add Action…") { addNew() }
                .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            Button { addNew() } label: { Image(systemName: "plus").frame(width: 24, height: 20) }
                .help("Add an action")
            Divider().frame(height: 16)
            Button { delete(selection) } label: { Image(systemName: "minus").frame(width: 24, height: 20) }
                .disabled(selection.isEmpty)
                .help("Remove the selected actions")
            Spacer()
            Button("Edit…") {
                if let id = selection.first, let a = action(id) { editing = EditRequest(action: a, isNew: false) }
            }
            .disabled(selection.count != 1)
            .controlSize(.small)
            .padding(.trailing, 6)
        }
        .buttonStyle(.borderless)
        .padding(4)
    }

    // MARK: Helpers

    private func action(_ id: CornerAction.ID) -> CornerAction? { config.actions.first { $0.id == id } }

    private func comboCount(_ a: CornerAction) -> Int {
        config.actions.filter { $0.groupKey == a.groupKey }.count
    }

    private func addNew() {
        editing = EditRequest(action: CornerAction(kind: .openItem), isNew: true)
    }

    private func duplicate(_ a: CornerAction) {
        var copy = a
        copy.id = UUID()
        store.update(displayKey: displayKey, corner: corner) { cfg in
            let i = (cfg.actions.firstIndex(of: a) ?? cfg.actions.count - 1) + 1
            cfg.actions.insert(copy, at: i)
        }
        selection = [copy.id]
    }

    private func delete(_ ids: Set<CornerAction.ID>) {
        guard !ids.isEmpty else { return }
        store.update(displayKey: displayKey, corner: corner) { $0.actions.removeAll { ids.contains($0.id) } }
        selection = []
    }
}

struct EditRequest: Identifiable {
    var action: CornerAction
    var isNew: Bool
    var id: UUID { action.id }
}

// MARK: - Action row

struct ActionRow: View {
    let action: CornerAction
    let combo: Int

    var body: some View {
        HStack(spacing: 10) {
            ActionIcon(action: action, size: 26)
            VStack(alignment: .leading, spacing: 1) {
                Text(action.displayName).lineLimit(1)
                if !subtitle.isEmpty && subtitle != action.displayName {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            Spacer()
            if combo > 1 {
                Image(systemName: "link")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .help("Runs together with \(combo - 1) other action\(combo == 2 ? "" : "s") on the same trigger")
            }
            TriggerChip(text: action.triggerDescription)
        }
        .padding(.vertical, 3)
    }

    private var subtitle: String {
        switch action.kind {
        case .openItem, .runAppleScript:
            return (action.target as NSString).abbreviatingWithTildeInPath
        case .openURL:
            return action.target
        case .runShortcut:
            return "Shortcut"
        default:
            return action.label.isEmpty ? "" : action.kind.title
        }
    }
}

struct TriggerChip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.callout.monospacedDigit())
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Capsule().fill(.quaternary))
    }
}

// MARK: - Screen preview

struct ScreenPreview: View {
    let screen: NSScreen?
    let layout: CornerLayout
    @Binding var selected: Corner
    let hotCorners: [Corner: String]

    @State private var desktopPicture: NSImage?
    @State private var pictureLoaded = false

    private var aspect: CGFloat {
        guard let f = screen?.frame, f.height > 0 else { return 16 / 10 }
        return f.width / f.height
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
            // Color.clear pins this layer to the proposed size, so the .fill wallpaper is cropped
            // by the clip shape instead of growing the ZStack past the frame set on the preview.
            Color.clear
                .overlay { wallpaper }
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                .padding(5)
                .overlay(alignment: .top) {
                    // Menu bar strip
                    Rectangle().fill(.ultraThinMaterial)
                        .frame(height: 9)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 7, topTrailingRadius: 7, style: .continuous))
                        .padding([.horizontal, .top], 5)
                }
            GeometryReader { geo in
                ForEach(Corner.allCases) { c in
                    CornerButton(corner: c,
                                 count: layout[c].actions.count,
                                 enabled: layout[c].enabled,
                                 isSelected: selected == c,
                                 conflict: hotCorners[c] != nil && !layout[c].actions.isEmpty) {
                        withAnimation(.snappy(duration: 0.2)) { selected = c }
                    }
                    .position(x: c.isLeft ? 22 : geo.size.width - 22,
                              y: c.isTop ? 26 : geo.size.height - 22)
                }
            }
        }
        .aspectRatio(aspect, contentMode: .fit)
        // Belt and braces: nothing in this stack may paint over the display bar above or the
        // action list below, whatever a future child reports as its size. Must stay before
        // .shadow, which draws outside the shape on purpose.
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Screen corners")
        .task(id: screen?.displayUUID) { await loadDesktopPicture() }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            Task { await loadDesktopPicture() }
        }
    }

    /// Reads the desktop picture once per display, off the main thread. This used to happen
    /// inline in `wallpaper`, so a full-resolution image was re-read and re-decoded on every
    /// body evaluation — including on every corner tap, inside the selection animation.
    @MainActor private func loadDesktopPicture() async {
        var picture: NSImage?
        if let screen, let url = NSWorkspace.shared.desktopImageURL(for: screen) {
            let data = await Task.detached(priority: .userInitiated) { try? Data(contentsOf: url) }.value
            if let data, let img = NSImage(data: data), img.isValid { picture = img }
        }
        desktopPicture = picture
        pictureLoaded = true
    }

    @ViewBuilder private var wallpaper: some View {
        if let desktopPicture {
            Image(nsImage: desktopPicture).resizable().aspectRatio(contentMode: .fill)
        } else if pictureLoaded {
            LinearGradient(colors: [Color(red: 0.16, green: 0.32, blue: 0.75), Color(red: 0.45, green: 0.22, blue: 0.7)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            // First read still in flight: let the black card show through rather than flashing
            // the gradient, which means "this Mac has no desktop picture".
            Color.clear
        }
    }
}

struct CornerButton: View {
    let corner: Corner
    let count: Int
    let enabled: Bool
    let isSelected: Bool
    let conflict: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.regularMaterial))
                    .overlay(Circle().strokeBorder(.white.opacity(isSelected ? 0.9 : 0.35), lineWidth: isSelected ? 2 : 1))
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                        .foregroundStyle(isSelected ? .white : .primary)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : .secondary)
                }
            }
            .frame(width: 30, height: 30)
            .opacity(enabled ? 1 : 0.5)
            .overlay(alignment: .topTrailing) {
                if conflict {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow, .black)
                        .offset(x: 4, y: -4)
                }
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .help("\(corner.title): \(count) action\(count == 1 ? "" : "s")\(enabled ? "" : " (off)")")
        .accessibilityLabel("\(corner.title) corner, \(count) actions")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct Banner: View {
    let symbol: String
    let tint: Color
    let text: String
    let button: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol).foregroundStyle(tint).font(.title3)
            Text(text).fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(button, action: action).controlSize(.small)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(tint.opacity(0.12)))
    }
}

// MARK: - Action editor

struct ActionEditor: View {
    let original: CornerAction
    let isNew: Bool
    let siblings: [CornerAction]
    let onSave: (CornerAction) -> Void

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = SettingsStore.shared
    @State private var draft: CornerAction
    @State private var shortcuts: [String] = []

    init(original: CornerAction, isNew: Bool, siblings: [CornerAction], onSave: @escaping (CornerAction) -> Void) {
        self.original = original
        self.isNew = isNew
        self.siblings = siblings
        self.onSave = onSave
        _draft = State(initialValue: original)
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    Picker("Action", selection: $draft.kind) {
                        ForEach(ActionKind.groups, id: \.0) { group in
                            Section(group.0) {
                                ForEach(group.1) { k in
                                    Label(k.title, systemImage: k.symbol).tag(k)
                                }
                            }
                        }
                    }
                    targetField
                    TextField("Label", text: $draft.label, prompt: Text(defaultLabel))
                }

                Section {
                    Picker("Trigger", selection: $draft.trigger) {
                        ForEach(Trigger.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    if draft.trigger == .hover {
                        Toggle(isOn: $draft.delayed) {
                            Text("Wait before running")
                            Text("Runs after you rest the pointer in the corner for \(store.settings.hoverDelay, specifier: "%.1f") s. Change the delay in General.")
                        }
                    }

                    LabeledContent("Modifier Keys") {
                        HStack(spacing: 4) {
                            ForEach(Modifiers.ordered, id: \.1) { mod, symbol, name in
                                Toggle(isOn: Binding(
                                    get: { draft.modifiers.contains(mod) },
                                    set: { on in if on { draft.modifiers.insert(mod) } else { draft.modifiers.remove(mod) } })) {
                                    Text(symbol).frame(minWidth: 18)
                                }
                                .toggleStyle(.button)
                                .help(name)
                            }
                        }
                    }
                } footer: {
                    if !combo.isEmpty {
                        Label("Runs together with \(combo.map(\.displayName).joined(separator: ", ")).",
                              systemImage: "link")
                            .font(.footnote).foregroundStyle(.secondary)
                    } else if draft.kind == .runAppleScript {
                        Text("macOS asks for permission the first time a script controls another app.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
            .formStyle(.grouped)

            Divider()
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button(isNew ? "Add" : "Save") {
                    var a = draft
                    a.target = a.target.trimmingCharacters(in: .whitespacesAndNewlines)
                    a.label = a.label.trimmingCharacters(in: .whitespacesAndNewlines)
                    if a.trigger != .hover { a.delayed = false }
                    if !a.kind.needsTarget { a.target = "" }
                    onSave(a)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!draft.isValid)
            }
            .padding(16)
        }
        .frame(width: 480)
        .fixedSize(horizontal: false, vertical: true)
        .task(id: draft.kind) {
            if draft.kind == .runShortcut && shortcuts.isEmpty { shortcuts = await ShortcutsList.load() }
        }
    }

    private var combo: [CornerAction] {
        siblings.filter { $0.id != draft.id && $0.groupKey == draft.groupKey }
    }

    private var defaultLabel: String {
        var a = draft; a.label = ""
        return a.displayName
    }

    @ViewBuilder private var targetField: some View {
        switch draft.kind {
        case .openItem:
            LabeledContent("Item") {
                FileChooser(path: $draft.target, types: nil, directory: "/Applications")
            }
        case .runAppleScript:
            LabeledContent("Script") {
                FileChooser(path: $draft.target,
                            types: [UTType(filenameExtension: "scpt"), UTType(filenameExtension: "applescript"),
                                    UTType(filenameExtension: "scptd")].compactMap { $0 },
                            directory: "~/Library/Scripts")
            }
        case .openURL:
            TextField("URL", text: $draft.target, prompt: Text("https://example.com"))
                .textContentType(.URL)
        case .runShortcut:
            if shortcuts.isEmpty {
                TextField("Shortcut", text: $draft.target, prompt: Text("Shortcut name"))
            } else {
                Picker("Shortcut", selection: $draft.target) {
                    if draft.target.isEmpty { Text("Choose…").tag("") }
                    if !draft.target.isEmpty && !shortcuts.contains(draft.target) {
                        Text(draft.target).tag(draft.target)
                    }
                    ForEach(shortcuts, id: \.self) { Text($0).tag($0) }
                }
            }
        default:
            EmptyView()
        }
    }
}

struct FileChooser: View {
    @Binding var path: String
    let types: [UTType]?
    let directory: String

    var body: some View {
        HStack(spacing: 8) {
            if !path.isEmpty {
                Image(nsImage: NSWorkspace.shared.icon(forFile: (path as NSString).expandingTildeInPath))
                    .resizable().frame(width: 20, height: 20)
                Text((path as NSString).lastPathComponent)
                    .lineLimit(1).truncationMode(.middle)
                    .help(path)
            }
            Button(path.isEmpty ? "Choose…" : "Change…") { choose() }
        }
    }

    private func choose() {
        let p = NSOpenPanel()
        p.canChooseFiles = true
        p.canChooseDirectories = types == nil
        p.allowsMultipleSelection = false
        p.treatsFilePackagesAsDirectories = false
        if let types { p.allowedContentTypes = types }
        let start = path.isEmpty ? directory : ((path as NSString).deletingLastPathComponent)
        p.directoryURL = URL(fileURLWithPath: (start as NSString).expandingTildeInPath)
        p.prompt = "Choose"
        if let sheetWindow = NSApp.keyWindow {
            p.beginSheetModal(for: sheetWindow) { resp in
                if resp == .OK, let url = p.url { path = url.path }
            }
        } else if p.runModal() == .OK, let url = p.url {
            path = url.path
        }
    }
}

enum ShortcutsList {
    static func load() async -> [String] {
        await withCheckedContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                let p = Process()
                p.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
                p.arguments = ["list"]
                let out = Pipe()
                p.standardOutput = out
                p.standardError = FileHandle.nullDevice
                do { try p.run() } catch { cont.resume(returning: []); return }
                let data = out.fileHandleForReading.readDataToEndOfFile()
                p.waitUntilExit()
                let names = String(data: data, encoding: .utf8)?
                    .split(separator: "\n").map(String.init).filter { !$0.isEmpty } ?? []
                cont.resume(returning: names.sorted { $0.localizedStandardCompare($1) == .orderedAscending })
            }
        }
    }
}

// MARK: - System Hot Corners

enum SystemHotCorners {
    private static let names: [Int: String] = [
        2: "Mission Control", 3: "Application Windows", 4: "Desktop", 5: "Start Screen Saver",
        6: "Disable Screen Saver", 7: "Dashboard", 10: "Put Display to Sleep", 11: "Launchpad",
        12: "Notification Center", 13: "Lock Screen", 14: "Quick Note",
    ]

    static func read() -> [Corner: String] {
        guard let dock = UserDefaults.standard.persistentDomain(forName: "com.apple.dock") else { return [:] }
        var out: [Corner: String] = [:]
        for c in Corner.allCases {
            if let v = (dock[c.dockHotCornerKey] as? NSNumber)?.intValue, v > 1 {
                out[c] = names[v] ?? "Hot Corner"
            }
        }
        return out
    }

    static func openSettings() {
        let urls = ["x-apple.systempreferences:com.apple.Desktop-Settings.extension?HotCorners",
                    "x-apple.systempreferences:com.apple.Desktop-Settings.extension"]
        for s in urls {
            if let u = URL(string: s), NSWorkspace.shared.open(u) { return }
        }
    }
}

// MARK: - General tab

struct GeneralView: View {
    @ObservedObject private var store = SettingsStore.shared
    @State private var loginEnabled = SMAppService.mainApp.status == .enabled
    @State private var loginNeedsApproval = SMAppService.mainApp.status == .requiresApproval
    @State private var importMessage: String?
    @State private var hotCorners = SystemHotCorners.read()

    var body: some View {
        Form {
            Section {
                Toggle("Enable CornerClick", isOn: $store.settings.enabled)
                Toggle(isOn: Binding(get: { loginEnabled }, set: setLogin)) {
                    Text("Open at Login")
                    if loginNeedsApproval {
                        Text("Approve CornerClick in System Settings › General › Login Items.")
                    }
                }
                Toggle(isOn: $store.settings.showInMenuBar) {
                    Text("Show in Menu Bar")
                    Text("When hidden, open CornerClick again from Applications to see Settings.")
                }
            }

            Section("Action List") {
                Toggle("Show actions when pointing at a corner", isOn: $store.settings.showHUD)
                LabeledContent("Show After") {
                    HStack {
                        Slider(value: $store.settings.hudDelay, in: 0...2, step: 0.1)
                        Text(store.settings.hudDelay == 0 ? "Instantly" : String(format: "%.1f s", store.settings.hudDelay))
                            .monospacedDigit().foregroundStyle(.secondary).frame(width: 64, alignment: .trailing)
                    }
                }
                .disabled(!store.settings.showHUD)
                Picker("Size", selection: $store.settings.hudSize) {
                    ForEach(HUDSize.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
                .disabled(!store.settings.showHUD)
            }

            Section("Corners") {
                LabeledContent("Delayed Hover") {
                    HStack {
                        Slider(value: $store.settings.hoverDelay, in: 0.25...5, step: 0.25)
                        Text(String(format: "%.2g s", store.settings.hoverDelay))
                            .monospacedDigit().foregroundStyle(.secondary).frame(width: 64, alignment: .trailing)
                    }
                }
                LabeledContent("Hot Area Size") {
                    HStack {
                        Slider(value: $store.settings.hotAreaSize, in: 2...24, step: 1)
                        Text("\(Int(store.settings.hotAreaSize)) pt")
                            .monospacedDigit().foregroundStyle(.secondary).frame(width: 64, alignment: .trailing)
                    }
                }
                Toggle(isOn: $store.settings.showIndicators) {
                    Text("Show corner indicators")
                    Text("A small tint marks corners that have actions.")
                }
            }

            Section {
                LabeledContent("macOS Hot Corners") {
                    Button("Open Settings…") { SystemHotCorners.openSettings() }
                }
            } footer: {
                Text(hotCorners.isEmpty
                     ? "No macOS Hot Corners are set, so nothing competes with CornerClick."
                     : "macOS Hot Corners are set on: \(hotCorners.keys.sorted { $0.rawValue < $1.rawValue }.map(\.title).joined(separator: ", ")). Turn them off for corners you use with CornerClick.")
                    .font(.footnote).foregroundStyle(.secondary)
            }

            Section {
                LabeledContent("CornerClick 0.9 Settings") {
                    HStack {
                        if store.legacyPreferencesAvailable {
                            Button("Import from This Mac") { importFromDefaults() }
                        }
                        Button("Import File…") { importFile() }
                    }
                }
            } footer: {
                Text(importMessage ?? "Bring over corners from the original preference pane, e.g. a us.vario.greg.CornerClick.plist from an older Mac or backup.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: settingsTabWidth)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            refreshLogin()
            hotCorners = SystemHotCorners.read()
        }
    }

    private func setLogin(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
        } catch {
            NSLog("CornerClick: login item error: %@", error.localizedDescription)
        }
        refreshLogin()
    }

    private func refreshLogin() {
        let s = SMAppService.mainApp.status
        loginEnabled = s == .enabled
        loginNeedsApproval = s == .requiresApproval
    }

    private func importFromDefaults() {
        let n = store.importLegacyFromDefaults()
        importMessage = n > 0 ? "Imported \(n) action\(n == 1 ? "" : "s")." : "No actions found."
    }

    private func importFile() {
        let p = NSOpenPanel()
        p.allowedContentTypes = [.propertyList]
        p.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Preferences")
        p.message = "Choose a CornerClick preferences file (us.vario.greg.CornerClick.plist)"
        guard p.runModal() == .OK, let url = p.url else { return }
        do {
            let n = try store.importLegacy(fileURL: url)
            importMessage = "Imported \(n) action\(n == 1 ? "" : "s") from \(url.lastPathComponent)."
        } catch {
            importMessage = "That file doesn’t contain CornerClick corners."
        }
    }
}

// MARK: - About tab

struct AboutView: View {
    private var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return b.isEmpty || b == v ? "Version \(v)" : "Version \(v) (\(b))"
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable().frame(width: 96, height: 96)
            Text("CornerClick").font(.title.weight(.semibold))
            Text(version).foregroundStyle(.secondary)
            Text("Turn the four corners of your screen into buttons that never move.")
                .multilineTextAlignment(.center)
                .padding(.top, 4)
            Divider().padding(.vertical, 6).frame(width: 260)
            Text("Originally created by Greg Schueler, 2003–2010.\nRebuilt in 2026 for Apple silicon by Jens Nørgaard-Offersen with Claude Code.")
                .font(.callout).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                Link("Source Code", destination: URL(string: "https://github.com/B-E-N-D-E-R/CornerClick-1.0")!)
                Link("Apache License 2.0", destination: URL(string: "https://www.apache.org/licenses/LICENSE-2.0")!)
            }
            .font(.callout)
            .padding(.top, 4)
        }
        // The tab is as wide as Corners needs, but the content keeps the measure it was laid
        // out for (the old 460pt tab less its padding), so lines wrap instead of stretching.
        .frame(maxWidth: 396)
        .padding(32)
        .frame(width: settingsTabWidth)
    }
}
