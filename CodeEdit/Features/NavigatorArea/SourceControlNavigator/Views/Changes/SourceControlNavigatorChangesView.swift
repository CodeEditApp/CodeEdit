//
//  SourceControlNavigatorChangesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorChangesView: View {
    @ObservedObject var sourceControlManager: SourceControlManager

    @EnvironmentObject var workspace: WorkspaceDocument

    @State var selection = Set<CEWorkspaceFile>()

    var showSyncView: Bool {
        sourceControlManager.numberOfUnsyncedCommits > 0 ||
            (sourceControlManager.currentBranch != nil && sourceControlManager.currentBranch?.upstream == nil)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if sourceControlManager.changedFiles.isEmpty {
                if showSyncView {
                    SourceControlNavigatorSyncView(sourceControlManager: sourceControlManager)
                } else {
                    Text("No Changes")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            } else {
                SourceControlNavigatorChangesCommitView(
                    sourceControlManager: sourceControlManager
                )
                List($sourceControlManager.changedFiles, id: \.self, selection: $selection) { $file in
                    SourceControlNavigatorChangedFileView(
                        sourceControlManager: sourceControlManager,
                        changedFile: $file
                    )
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
            }
        }
        .frame(maxHeight: .infinity)
        .task {
            await sourceControlManager.refreshAllChangedFiles()
            await sourceControlManager.refreshNumberOfUnsyncedCommits()
        }
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
