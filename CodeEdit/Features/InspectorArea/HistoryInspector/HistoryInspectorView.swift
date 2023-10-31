//
//  HistoryInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct HistoryInspectorView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    @EnvironmentObject private var editorManager: EditorManager

    @ObservedObject private var model: HistoryInspectorModel

    @State var selectedCommitHistory: GitCommit?

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
                        HistoryInspectorNoHistoryView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List(selection: $selectedCommitHistory) {
                            ForEach(model.commitHistory) { commit in
                                HistoryInspectorItemView(commit: commit, selection: $selectedCommitHistory)
                                    .tag(commit)
                            }
                        }
                        .listStyle(.inset)
                    }
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .onChange(of: editorManager.activeEditor) { _ in
            Task {
                await model.setFile(url: editorManager.activeEditor.selectedTab?.url.path)
            }
        }
        .onChange(of: editorManager.activeEditor.selectedTab) { _ in
            Task {
                await model.setFile(url: editorManager.activeEditor.selectedTab?.url.path)
            }
        }
        .task {
            await model.setWorkspace(sourceControlManager: workspace.sourceControlManager)
            await model.setFile(url: editorManager.activeEditor.selectedTab?.url.path)
        }
    }
}
