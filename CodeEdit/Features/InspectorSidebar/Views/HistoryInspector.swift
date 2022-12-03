//
//  HistoryInspector.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI

struct HistoryInspector: View {

    @ObservedObject
    private var model: HistoryInspectorModel

    @State var selectedCommitHistory: Commit?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init(workspaceURL: URL, fileURL: String) {
        self.model = .init(workspaceURL: workspaceURL, fileURL: fileURL)
    }

    var body: some View {
        VStack {
            if model.commitHistory.isEmpty {
                NoCommitHistoryView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedCommitHistory) {
                    ForEach(model.commitHistory) { commit in
                        HistoryItem(commit: commit, selection: $selectedCommitHistory)
                            .tag(commit)
                    }
                }
                .listStyle(.inset)
            }
        }
    }
}
