//
//  FileInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import CodeEditLanguages

struct FileInspectorView: View {
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @EnvironmentObject
    private var tabManager: TabManager

    @AppSettings(\.textEditing)
    private var textEditing

    @State
    private var file: CEWorkspaceFile?

    @State
    private var fileName: String = ""

    @State
    private var language: CodeLanguage?

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
                        tabWidths
                        wrapLines
                    }
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .onReceive(tabManager.activeTabGroup.objectWillChange) { _ in
            file = tabManager.activeTabGroup.selected
            fileName = file?.name ?? ""
            language = file?.fileDocument?.language
        }
        .onAppear {
            file = tabManager.activeTabGroup.selected
            fileName = file?.name ?? ""
            language = file?.fileDocument?.language
        }
    }

    @ViewBuilder
    private var fileNameField: some View {
        if let file {
            TextField("Name", text: $fileName)
                .background(
                    file.validateFileName(for: fileName) ? Color.clear : Color(errorRed)
                )
                .onSubmit {
                    if file.validateFileName(for: fileName) {
                        let destinationURL = file.url
                            .deletingLastPathComponent()
                            .appendingPathComponent(fileName)
                        if !file.isFolder {
                            tabManager.tabGroups.closeAllTabs(of: file)
                        }
                        DispatchQueue.main.async {
                            file.move(to: destinationURL)
                            let newItem = CEWorkspaceFile(url: destinationURL)
                            newItem.parent = file.parent
                            if !newItem.isFolder {
                                tabManager.openTab(item: newItem)
                            }
                        }
                    } else {
                        fileName = file.labelFileName()
                    }
                }
        }
    }

    @ViewBuilder
    private var fileType: some View {
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
                        if !file.isFolder {
                            tabManager.tabGroups.closeAllTabs(of: file)
                        }
                        // This is ugly but if the tab is opened at the same time as closing the others, it doesn't open
                        // And if the files are re-built at the same time as the tab is opened, it causes a memory error
                        DispatchQueue.main.async {
                            file.move(to: newURL)
                            // If the parent directory doesn't exist in the workspace, don't open it in a tab.
                            if let newParent = try? workspace.workspaceFileManager?.getFile(
                                newURL.deletingLastPathComponent().path
                            ) {
                                let newItem = CEWorkspaceFile(url: newURL)
                                newItem.parent = newParent
                                if !file.isFolder {
                                    tabManager.openTab(item: newItem)
                                }
                                DispatchQueue.main.async {
                                    _ = try? workspace.workspaceFileManager?.rebuildFiles(fromItem: newParent)
                                }
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
        IndentOptionView()
    }

    private var tabWidths: some View {
        TabWidthOptionView()
    }

    private var wrapLines: some View {
        Toggle("Wrap lines to editor width", isOn: $textEditing.wrapLinesToEditorWidth)
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
