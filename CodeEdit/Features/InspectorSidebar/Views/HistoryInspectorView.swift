//
//  HistoryInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct HistoryInspectorView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    @EnvironmentObject private var tabManager: TabManager

    @ObservedObject private var model: HistoryInspectorModel

    @State var selectedCommitHistory: GitCommit?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init() {
        self.model = .init()
    }

    var body: some View {
        Group {
            if model.gitClient != nil {
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
        .onReceive(tabManager.activeTabGroup.objectWillChange) { _ in
            model.setFile(url: tabManager.activeTabGroup.selected?.url.path)
        }
        .onAppear {
            model.setWorkspace(url: workspace.fileURL)
            model.setFile(url: tabManager.activeTabGroup.selected?.url.path)
        }
    }
}
