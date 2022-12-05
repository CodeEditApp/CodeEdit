//
//  HistoryInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct HistoryInspectorView: View {

    @ObservedObject
    private var model: HistoryInspectorModel

    @State var selectedCommitHistory: GitCommit?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init(workspaceURL: URL, fileURL: String) {
        self.model = .init(workspaceURL: workspaceURL, fileURL: fileURL)
    }

    var body: some View {
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
    }
}
