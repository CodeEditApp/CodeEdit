//
//  FileInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import CodeEditLanguages

struct FileInspectorView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    @EnvironmentObject private var editorManager: EditorManager

    @AppSettings(\.textEditing)
    private var textEditing

    @State private var file: CEWorkspaceFile?

    @State private var fileName: String = ""

    // File settings overrides

    @State private var language: CodeLanguage?

    @State var indentOption: SettingsData.TextEditingSettings.IndentOption = .init(indentType: .tab)

    @State var defaultTabWidth: Int = 0

    @State var wrapLines: Bool = false

    func updateFileOptions(_ textEditingOverride: SettingsData.TextEditingSettings? = nil) {
        let textEditingSettings = textEditingOverride ?? textEditing
        indentOption = file?.fileDocument?.indentOption ?? textEditingSettings.indentOption
        defaultTabWidth = file?.fileDocument?.defaultTabWidth ?? textEditingSettings.defaultTabWidth
        wrapLines = file?.fileDocument?.wrapLines ?? textEditingSettings.wrapLinesToEditorWidth
    }

    func updateInspectorSource() {
        file = editorManager.activeEditor.selectedTab?.file
        fileName = file?.name ?? ""
        language = file?.fileDocument?.language
        updateFileOptions()
    }

    var body: some View {
        Group {
            if file != nil {
                Form {
                    Section("Identity and Type") {
                        fileNameField
                        fileType
                    }
                    Section {
                        location
                    }
                    Section("Text Settings") {
                        indentUsing
                        widthOptions
                        wrapLinesToggle
                    }
                    Section("Test Notifications") {
                        Button("Add Notification") {
                            let (iconSymbol, iconColor) = randomSymbolAndColor()
                            NotificationManager.shared.post(
                                iconSymbol: iconSymbol,
                                iconColor: iconColor,
                                title: "Test Notification",
                                description: "This is a test notification.",
                                actionButtonTitle: "Action",
                                action: {
                                    print("Test notification action triggered")
                                }
                            )
                        }
                        Button("Add Sticky Notification") {
                            NotificationManager.shared.post(
                                iconSymbol: "pin.fill",
                                iconColor: .orange,
                                title: "Sticky Notification",
                                description: "This notification will stay until dismissed.",
                                actionButtonTitle: "Acknowledge",
                                action: {
                                    print("Sticky notification acknowledged")
                                },
                                isSticky: true
                            )
                        }
                        Button("Add Image Notification") {
                            NotificationManager.shared.post(
                                iconImage: randomImage(),
                                title: "Test Notification with Image",
                                description: "This is a test notification with a custom image.",
                                actionButtonTitle: "Action",
                                action: {
                                    print("Test notification action triggered")
                                }
                            )
                        }
                        Button("Add Text Notification") {
                            NotificationManager.shared.post(
                                iconText: randomLetter(),
                                iconTextColor: .white,
                                iconColor: randomColor(),
                                title: "Text Notification",
                                description: "This is a test notification with text.",
                                actionButtonTitle: "Acknowledge",
                                action: {
                                    print("Test notification action triggered")
                                }
                            )
                        }
                        Button("Add Emoji Notification") {
                            NotificationManager.shared.post(
                                iconText: randomEmoji(),
                                iconTextColor: .white,
                                iconColor: randomColor(),
                                title: "Emoji Notification",
                                description: "This is a test notification with an emoji.",
                                actionButtonTitle: "Acknowledge",
                                action: {
                                    print("Test notification action triggered")
                                }
                            )
                        }
                    }
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .onAppear {
            updateInspectorSource()
        }
        .onReceive(editorManager.activeEditor.objectWillChange) { _ in
            updateInspectorSource()
        }
        .onChange(of: editorManager.activeEditor) { _ in
            updateInspectorSource()
        }
        .onChange(of: editorManager.activeEditor.selectedTab) { _ in
            updateInspectorSource()
        }
        .onChange(of: textEditing) { newValue in
            updateFileOptions(newValue)
        }
    }

    func randomColor() -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .mint, .cyan,
            .teal, .blue, .indigo, .purple, .pink, .gray
        ]
        return colors.randomElement() ?? .black
    }

    func randomSymbolAndColor() -> (String, Color) {
        let symbols: [(String, Color)] = [
            ("bell.fill", .red),
            ("bell.badge.fill", .red),
            ("exclamationmark.triangle.fill", .orange),
            ("info.circle.fill", .blue),
            ("checkmark.seal.fill", .green),
            ("xmark.octagon.fill", .red),
            ("bubble.left.fill", .teal),
            ("envelope.fill", .blue),
            ("phone.fill", .green),
            ("megaphone.fill", .pink),
            ("clock.fill", .gray),
            ("calendar", .red),
            ("flag.fill", .green),
            ("bookmark.fill", .orange),
            ("bolt.fill", .indigo),
            ("shield.lefthalf.fill", .red),
            ("gift.fill", .purple),
            ("heart.fill", .pink),
            ("star.fill", .orange),
            ("curlybraces", .cyan),
        ]
        return symbols.randomElement() ?? ("bell.fill", .red)
    }

    func randomEmoji() -> String {
        let emoji: [String] = [
            "🔔", "🚨", "⚠️", "👋", "😍", "😎", "😘", "😜", "😝", "😀", "😁",
            "😂", "🤣", "😃", "😄", "😅", "😆", "😇", "😉", "😊", "😋", "😌"
        ]
        return emoji.randomElement() ?? "🔔"
    }

    func randomImage() -> Image {
        let images: [Image] = [
            Image("GitHubIcon"),
            Image("BitBucketIcon"),
            Image("GitLabIcon")
        ]
        return images.randomElement() ?? Image("GitHubIcon")
    }

    func randomLetter() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
        return letters.randomElement() ?? "A"
    }

    @ViewBuilder private var fileNameField: some View {
        @State var isValid: Bool = true

        if let file {
            TextField("Name", text: $fileName)
                .background(
                    isValid ? Color.clear : Color(errorRed)
                )
                .onSubmit {
                    if file.validateFileName(for: fileName) {
                        let destinationURL = file.url
                            .deletingLastPathComponent()
                            .appendingPathComponent(fileName)
                        isValid = true
                        DispatchQueue.main.async { [weak workspace] in
                            do {
                                if let newItem = try workspace?.workspaceFileManager?.move(
                                    file: file,
                                    to: destinationURL
                                ),
                                   !newItem.isFolder {
                                    editorManager.editorLayout.closeAllTabs(of: file)
                                    editorManager.openTab(item: newItem)
                                }
                            } catch {
                                let alert = NSAlert(error: error)
                                alert.addButton(withTitle: "Dismiss")
                                alert.runModal()
                            }
                        }
                    } else {
                        isValid = false
                        fileName = file.labelFileName()
                    }
                }
        }
    }

    @ViewBuilder private var fileType: some View {
        Picker(
            "Type",
            selection: $language
        ) {
            Text("Default - Detected").tag(nil as CodeLanguage?)
            Divider()
            ForEach(CodeLanguage.allLanguages, id: \.id) { language in
                Text(language.id.rawValue.capitalized).tag(language as CodeLanguage?)
            }
        }
        .onChange(of: language) { newValue in
            file?.fileDocument?.language = newValue
        }
    }

    private var location: some View {
        Group {
            if let file {
                LabeledContent("Location") {
                    Button("Choose...") {
                        guard let newURL = chooseNewFileLocation() else {
                            return
                        }
                        // This is ugly but if the tab is opened at the same time as closing the others, it doesn't open
                        // And if the files are re-built at the same time as the tab is opened, it causes a memory error
                        DispatchQueue.main.async { [weak workspace] in
                            do {
                                guard let newItem = try workspace?.workspaceFileManager?.move(file: file, to: newURL),
                                      !newItem.isFolder else {
                                    return
                                }
                                editorManager.editorLayout.closeAllTabs(of: file)
                                editorManager.openTab(item: newItem)
                            } catch {
                                let alert = NSAlert(error: error)
                                alert.addButton(withTitle: "Dismiss")
                                alert.runModal()
                            }
                        }
                    }
                }
                ExternalLink(showInFinder: true, destination: file.url) {
                    Text(file.url.path(percentEncoded: false))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var indentUsing: some View {
        Picker("Indent using", selection: $indentOption.indentType) {
            Text("Spaces").tag(SettingsData.TextEditingSettings.IndentOption.IndentType.spaces)
            Text("Tabs").tag(SettingsData.TextEditingSettings.IndentOption.IndentType.tab)
        }
        .onChange(of: indentOption) { newValue in
            file?.fileDocument?.indentOption = newValue == textEditing.indentOption ? nil : newValue
        }
    }

    private var widthOptions: some View {
        LabeledContent("Widths") {
            HStack(spacing: 5) {
                VStack(alignment: .center, spacing: 0) {
                    Stepper(
                        "",
                        value: Binding<Double>(
                            get: { Double(defaultTabWidth) },
                            set: { defaultTabWidth = Int($0) }
                        ),
                        in: 1...16,
                        step: 1,
                        format: .number
                    )
                    .labelsHidden()
                    Text("Tab")
                        .foregroundColor(.primary)
                        .font(.footnote)
                }
                .help("The visual width of tab characters")
                VStack(alignment: .center, spacing: 0) {
                    Stepper(
                        "",
                        value: Binding<Double>(
                            get: { Double(indentOption.spaceCount) },
                            set: { indentOption.spaceCount = Int($0) }
                        ),
                        in: 1...10,
                        step: 1,
                        format: .number
                    )
                    .labelsHidden()
                    Text("Indent")
                        .foregroundColor(.primary)
                        .font(.footnote)
                }
                .help("The number of spaces to insert when the tab key is pressed.")
            }
        }
        .onChange(of: defaultTabWidth) { newValue in
            file?.fileDocument?.defaultTabWidth = newValue == textEditing.defaultTabWidth ? nil : newValue
        }
    }

    private var wrapLinesToggle: some View {
        Toggle("Wrap lines", isOn: $wrapLines)
            .onChange(of: wrapLines) { newValue in
                file?.fileDocument?.wrapLines = newValue == textEditing.wrapLinesToEditorWidth ? nil : newValue
            }
    }

    private func chooseNewFileLocation() -> URL? {
        guard let file else { return nil }
        let dialogue = NSSavePanel()
        dialogue.title = "Save File"
        dialogue.directoryURL = file.url.deletingLastPathComponent()
        dialogue.nameFieldStringValue = file.name
        if dialogue.runModal() == .OK {
            return dialogue.url
        } else {
            return nil
        }
    }
}
