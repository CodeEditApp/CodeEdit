//
//  SourceControlNavigatorChangesList.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/18/23.
//

import SwiftUI

struct SourceControlNavigatorChangesList: View {
    @EnvironmentObject var workspace: WorkspaceDocument
    @EnvironmentObject var sourceControlManager: SourceControlManager

    @State var selection = Set<CEWorkspaceFile>()

    var body: some View {
        List($sourceControlManager.changedFiles, id: \.self, selection: $selection) { $file in
            SourceControlNavigatorChangedFileView(changedFile: $file)
                .listRowSeparator(.hidden)
        }
        .contextMenu(
            forSelectionType: CEWorkspaceFile.self,
            menu: { selectedFiles in
                if !selectedFiles.isEmpty,
                   selectedFiles.count == 1,
                   let file = selectedFiles.first {
                    Group {
                        Button("View in Finder") {
                            file.showInFinder()
                        }
                        Button("Reveal in Project Navigator") {}
                            .disabled(true) // TODO: Implementation Needed
                        Divider()
                    }
                    Group {
                        Button("Open in New Tab") {
                            DispatchQueue.main.async {
                                workspace.editorManager.activeEditor.openTab(item: file, asTemporary: true)
                            }
                        }
                        Button("Open in New Window") {}
                            .disabled(true) // TODO: Implementation Needed
                    }
                    if file.gitStatus == .modified {
                        Group {
                            Divider()
                            Button("Discard Changes in \(file.name)...") {
                                sourceControlManager.discardChanges(for: file)
                            }
                            Divider()
                        }
                    }
                } else {
                    EmptyView()
                }
            },
            // double-click action
            primaryAction: { selectedFiles in
                if !selectedFiles.isEmpty,
                   selectedFiles.count == 1,
                   let file = selection.first {
                    DispatchQueue.main.async {
                        workspace.editorManager.activeEditor.openTab(item: file, asTemporary: false)
                    }
                }
            }
        )
        .onChange(of: selection) { newSelection in
            if !newSelection.isEmpty,
               newSelection.count == 1,
               let file = newSelection.first {
                DispatchQueue.main.async {
                    workspace.editorManager.activeEditor.openTab(item: file, asTemporary: true)
                }
            }
        }
    }
}
