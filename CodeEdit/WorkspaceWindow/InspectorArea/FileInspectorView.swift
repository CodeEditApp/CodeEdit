//
//  FileInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import CodeEditSettings
import CodeEditCore
import CodeEditLanguages

struct FileInspectorView: View {
    @Environment(\.activeEditorState)
    private var activeEditorState

    @Environment(\.fileEditorOverrides)
    private var fileEditorOverrides
    @Environment(\.fileRelocator)
    private var fileRelocator

    @AppSettings(\.textEditing)
    private var textEditing

    @State private var file: CEWorkspaceFile?

    @State private var fileName: String = ""

    // File settings overrides

    @State private var languageId: String?

    @State var indentOption: TextEditingSettings.IndentOption = .init(indentType: .tab)

    @State var defaultTabWidth: Int = 0

    @State var wrapLines: Bool = false

    func updateFileOptions(_ textEditingOverride: TextEditingSettings? = nil) {
        let textEditingSettings = textEditingOverride ?? textEditing
        let values = file.map { fileEditorOverrides.overrides(for: $0) }
        indentOption = values?.indentOption ?? textEditingSettings.indentOption
        defaultTabWidth = values?.defaultTabWidth ?? textEditingSettings.defaultTabWidth
        wrapLines = values?.wrapLines ?? textEditingSettings.wrapLinesToEditorWidth
    }

    func updateInspectorSource() {
        file = activeEditorState.selectedFile
        fileName = file?.name ?? ""
        languageId = file.flatMap { fileEditorOverrides.overrides(for: $0).languageId }
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
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .onAppear {
            updateInspectorSource()
        }
        .onReceive(activeEditorState.selectedFilePublisher) { _ in
            updateInspectorSource()
        }
        .onChange(of: textEditing) { _, newValue in
            updateFileOptions(newValue)
        }
    }

    @ViewBuilder private var fileNameField: some View {
        if let file {
            TextField("Name", text: $fileName)
                .background(
                    fileName != file.fileName() && !file.validateFileName(for: fileName) ? Color(errorRed) : Color.clear
                )
                .onSubmit {
                    if file.validateFileName(for: fileName) {
                        let destinationURL = file.url
                            .deletingLastPathComponent()
                            .appending(path: fileName)
                        DispatchQueue.main.async {
                            do {
                                _ = try fileRelocator.relocate(file: file, to: destinationURL)
                            } catch {
                                let alert = NSAlert(error: error)
                                alert.addButton(withTitle: "Dismiss")
                                alert.runModal()
                            }
                        }
                    } else {
                        fileName = file.labelFileName()
                    }
                }
        }
    }

    @ViewBuilder private var fileType: some View {
        Picker(
            "Type",
            selection: $languageId
        ) {
            Text("Default - Detected").tag(nil as String?)
            Divider()
            ForEach(CodeLanguage.allLanguages, id: \.id) { language in
                Text(language.id.rawValue.capitalized).tag(language.id.rawValue as String?)
            }
        }
        .onChange(of: languageId) { _, newValue in
            if let file {
                fileEditorOverrides.setLanguageId(newValue, for: file)
            }
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
                        DispatchQueue.main.async {
                            do {
                                _ = try fileRelocator.relocate(file: file, to: newURL)
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
            Text("Spaces").tag(TextEditingSettings.IndentOption.IndentType.spaces)
            Text("Tabs").tag(TextEditingSettings.IndentOption.IndentType.tab)
        }
        .onChange(of: indentOption) { _, newValue in
            if let file {
                fileEditorOverrides.setIndentOption(newValue == textEditing.indentOption ? nil : newValue, for: file)
            }
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
        .onChange(of: defaultTabWidth) { _, newValue in
            if let file {
                fileEditorOverrides.setDefaultTabWidth(
                    newValue == textEditing.defaultTabWidth ? nil : newValue,
                    for: file
                )
            }
        }
    }

    private var wrapLinesToggle: some View {
        Toggle("Wrap lines", isOn: $wrapLines)
            .onChange(of: wrapLines) { _, newValue in
                if let file {
                    fileEditorOverrides.setWrapLines(
                        newValue == textEditing.wrapLinesToEditorWidth ? nil : newValue,
                        for: file
                    )
                }
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
