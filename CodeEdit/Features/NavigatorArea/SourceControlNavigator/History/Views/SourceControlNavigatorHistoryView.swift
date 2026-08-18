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

    @AppSettings(\.sourceControl.git.showMergeCommitsPerFileLog)
    var showMergeCommitsPerFileLog

    @EnvironmentObject var sourceControlManager: SourceControlManager

    @State var commitHistoryStatus: Status = .loading
    @State var commitHistory: [GitCommit] = []

    @State var selection: GitCommit?
    @State private var width: CGFloat = CGFloat.zero

    func updateCommitHistory() async {
        do {
            commitHistoryStatus = .loading
            let commits = try await sourceControlManager
                .gitClient
                .getCommitHistory(
                    branchName: sourceControlManager.currentBranch?.name,
                    showMergeCommits: Settings.shared.preferences.sourceControl.git.showMergeCommitsPerFileLog
                )
            await MainActor.run {
                commitHistory = commits
                commitHistoryStatus = .ready
            }
        } catch {
            sourceControlManager.logger.log("Failed to load commit history: \(error)")
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
                    GeometryReader { geometry in
                        ZStack {
                            List(selection: $selection) {
                                ForEach(commitHistory) { commit in
                                    CommitListItemView(commit: commit, showRef: true, width: width)
                                        .tag(commit)
                                        .listRowSeparator(.hidden)
                                }
                            }
                            .opacity(selection == nil ? 1 : 0)
                            if selection != nil {
                                CommitDetailsView(commit: $selection)
                            }
                        }
                        .onAppear {
                            self.width = geometry.size.width
                        }
                        .onChange(of: geometry.size.width) { _, newWidth in
                            self.width = newWidth
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
        .task {
            await updateCommitHistory()
        }
        .onChange(of: showMergeCommitsPerFileLog) { _, _ in
            Task {
                await updateCommitHistory()
            }
        }
    }
}
