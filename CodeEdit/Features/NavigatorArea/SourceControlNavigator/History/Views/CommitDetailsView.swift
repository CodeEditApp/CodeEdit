//
//  CommitDetailsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/23.
//

import SwiftUI

struct CommitDetailsView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager

    @Binding var commit: GitCommit?

    @State var commitChanges: [CEWorkspaceFile] = []

    @State var selection: CEWorkspaceFile?

    func updateCommitChanges() async throws {
        if let commit = commit {
            let changes = await sourceControlManager
                .getCommitChangedFiles(commitSHA: commit.commitHash)
            commitChanges = changes
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                commit = nil
            } label: {
                HStack(spacing: 2.5) {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(.secondary)
                    Text("History")
                        .font(.subheadline)
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            Divider()
            if let commit = commit {
                CommitDetailsHeaderView(commit: commit)
                    .padding(10)
                Divider()
                if !commitChanges.isEmpty {
                    List($commitChanges, id: \.self, selection: $selection) { $file in
                        CommitChangedFileListItemView(changedFile: $file)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, -1)
                    }
                    .environment(\.defaultMinListRowHeight, 22)
                } else {
                    CEContentUnavailableView("No Changes")
                }
            } else {
                Spacer()
            }
        }
        .onAppear {
            Task {
                try await updateCommitChanges()
            }
        }
    }
}
