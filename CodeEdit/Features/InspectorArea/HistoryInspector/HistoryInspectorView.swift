//
//  HistoryInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct HistoryInspectorView: View {
    @AppSettings(\.sourceControl.git.showMergeCommitsPerFileLog)
    var showMergeCommitsPerFileLog

    @EnvironmentObject private var workspace: WorkspaceDocument

    @EnvironmentObject private var editorManager: EditorManager

    @ObservedObject private var model: HistoryInspectorModel

    @State var selection: GitCommit?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init() {
        self.model = .init()
    }

    var body: some View {
        Group {
            if model.sourceControlManager != nil {
                VStack {
                    if model.commitHistory.isEmpty {
                        CEContentUnavailableView("No History")
                    } else {
                        List(selection: $selection) {
                            ForEach(model.commitHistory) { commit in
                                HistoryInspectorItemView(commit: commit, selection: $selection)
                                    .tag(commit)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .onReceive(editorManager.activeEditor.objectWillChange) { _ in
            Task {
                await model.setFile(url: editorManager.activeEditor.selectedTab?.file.url.path())
            }
        }
        .onChange(of: editorManager.activeEditor) { _, _ in
            Task {
                await model.setFile(url: editorManager.activeEditor.selectedTab?.file.url.path())
            }
        }
        .onChange(of: editorManager.activeEditor.selectedTab) { _, _ in
            Task {
                await model.setFile(url: editorManager.activeEditor.selectedTab?.file.url.path())
            }
        }
        .task {
            await model.setWorkspace(sourceControlManager: workspace.sourceControlManager)
            await model.setFile(url: editorManager.activeEditor.selectedTab?.file.url.path)
        }
        .onChange(of: showMergeCommitsPerFileLog) { _, _ in
            Task {
                await model.updateCommitHistory()
            }
        }
    }
}
