//
//  SourceControlNavigatorHistoryView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/2023.
//

import SwiftUI
import CodeEditSymbols

struct SourceControlNavigatorHistoryView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager

    @State var commitHistory: [GitCommit] = []

    @State var selection: GitCommit?

    func updateCommitHistory() async {
        do {
            let commits = try await sourceControlManager
                .gitClient
                .getCommitHistory(branchName: sourceControlManager.currentBranch?.name)
            commitHistory = commits
        } catch {
            commitHistory = []
        }
    }

    var body: some View {
        Group {
            if commitHistory.isEmpty {
                CEContentUnavailableView("No History")
            } else {
                ZStack {
                    List(selection: $selection) {
                        ForEach(commitHistory) { commit in
                            CommitListItemView(commit: commit)
                                .tag(commit)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .opacity(selection == nil ? 1 : 0)
                    if selection != nil {
                        CommitDetailsView(commit: $selection)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await updateCommitHistory()
            }
        }
    }
}
