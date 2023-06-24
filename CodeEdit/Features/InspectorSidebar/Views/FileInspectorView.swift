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

    @EnvironmentObject private var tabManager: TabManager

    @AppSettings(\.textEditing)
    private var textEditing

    @State private var file: File?

    @State private var fileName: String = ""

    // File settings overrides

    @State private var language: CodeLanguage?

    @State var indentOption: SettingsData.TextEditingSettings.IndentOption = .init(indentType: .tab)

    @State var defaultTabWidth: Int = 0

    @State var wrapLines: Bool = false

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
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .task(id: tabManager.activeTabGroup) {
            file = tabManager.activeTabGroup.selected
            fileName = file?.name ?? ""
            language = file?.document?.language
            indentOption = file?.document?.indentOption ?? textEditing.indentOption
            defaultTabWidth = file?.document?.defaultTabWidth ?? textEditing.defaultTabWidth
            wrapLines = file?.document?.wrapLines ?? textEditing.wrapLinesToEditorWidth
        }
        .onChange(of: textEditing) { newValue in
            indentOption = file?.document?.indentOption ?? newValue.indentOption
            defaultTabWidth = file?.document?.defaultTabWidth ?? newValue.defaultTabWidth
            wrapLines = file?.document?.wrapLines ?? newValue.wrapLinesToEditorWidth
        }
    }

    @ViewBuilder private var fileNameField: some View {
        if let file {
            TextField("Name", text: $fileName)
                .background(
                    file.validateFileName(for: fileName) ? Color.clear : Color(errorRed)
                )
                .onSubmit {
                    if file.validateFileName(for: fileName) {
                        // FIXME:
//                        let destinationURL = file.url
//                            .deletingLastPathComponent()
//                            .appendingPathComponent(fileName)
//
//                        tabManager.tabGroups.closeAllTabs(of: file)
//
//                        DispatchQueue.main.async {
//                            file.move(to: destinationURL)
//                            let newItem = CEWorkspaceFile(url: destinationURL)
//                            newItem.parent = file.parent
//                            if !newItem.isFolder {
//                                tabManager.openTab(item: newItem)
//                            }
//                        }
                    } else {
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
            file?.document?.language = newValue
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

                        tabManager.tabGroups.closeAllTabs(of: file)

                        // This is ugly but if the tab is opened at the same time as closing the others, it doesn't open
                        // And if the files are re-built at the same time as the tab is opened, it causes a memory error
                        // FIXME:
//                        DispatchQueue.main.async {
//                            file.move(to: newURL)
//                            // If the parent directory doesn't exist in the workspace, don't open it in a tab.
//                            if let newParent = try? workspace.workspaceFileManager?.getFile(
//                                newURL.deletingLastPathComponent().path
//                            ) {
//                                let newItem = CEWorkspaceFile(url: newURL)
//                                newItem.parent = newParent
//                                if !file.isFolder {
//                                    tabManager.openTab(item: newItem)
//                                }
//                                DispatchQueue.main.async {
//                                    _ = try? workspace.workspaceFileManager?.rebuildFiles(fromItem: newParent)
//                                }
//                            }
//                        }
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
            file?.document?.indentOption = newValue == textEditing.indentOption ? nil : newValue
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
            file?.document?.defaultTabWidth = newValue == textEditing.defaultTabWidth ? nil : newValue
        }
    }

    private var wrapLinesToggle: some View {
        Toggle("Wrap lines", isOn: $wrapLines)
            .onChange(of: wrapLines) { newValue in
                file?.document?.wrapLines = newValue == textEditing.wrapLinesToEditorWidth ? nil : newValue
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
