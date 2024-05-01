//
//  SourceControlNavigatorHistoryView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 12/27/2023.
//

import SwiftUI
import CodeEditSymbols

struct SourceControlNavigatorHistoryView: View {
    enum Status {
        case loading
        case ready
        case error(error: Error)
    }

    @EnvironmentObject var sourceControlManager: SourceControlManager

    @State var commitHistoryStatus: Status = .loading
    @State var commitHistory: [GitCommit] = []

    @State var selection: GitCommit?

    func updateCommitHistory() async {
        do {
            commitHistoryStatus = .loading
            let commits = try await sourceControlManager
                .gitClient
                .getCommitHistory(branchName: sourceControlManager.currentBranch?.name)
            await MainActor.run {
                commitHistory = commits
                commitHistoryStatus = .ready
            }
        } catch {
            await MainActor.run {
                commitHistory = []
                commitHistoryStatus = .error(error: error)
            }
        }
    }

    var body: some View {
        Group {
            switch commitHistoryStatus {
            case .loading:
                VStack {
                    Spacer()
                    ProgressView {
                        Text("Loading History")
                    }
                    Spacer()
                }
            case .ready:
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
            case .error(let error):
                VStack {
                    Spacer()
                    CEContentUnavailableView(
                        "Error Loading History",
                        description: error.localizedDescription,
                        systemImage: "exclamationmark.triangle"
                    ) {
                        Button {
                            Task {
                                await updateCommitHistory()
                            }
                        } label: {
                            Text("Retry")
                        }
                    }
                    Spacer()
                }
            }
        }
        .onReceive(sourceControlManager.$currentBranch) { _ in
            Task {
                await updateCommitHistory()
            }
        }
        .task {
            await updateCommitHistory()
        }
    }
}
