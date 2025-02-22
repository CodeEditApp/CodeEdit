//
//  HistoryInspectorModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/18.
//

import Foundation
import SwiftGitX

final class HistoryInspectorModel: ObservableObject {
    private(set) var sourceControlManager: SourceControlManager?

    /// The base URL of the workspace
    private(set) var workspaceURL: URL?

    /// The base URL of the workspace
    private(set) var fileURL: String?

    /// The selected branch from the GitClient
    @Published var commitHistory: [Commit] = []

    func setWorkspace(sourceControlManager: SourceControlManager?) async {
        self.sourceControlManager = sourceControlManager
        await updateCommitHistory()
    }

    func setFile(url: String?) async {
        if fileURL != url {
            fileURL = url
            await updateCommitHistory()
        }
    }

    func updateCommitHistory() async {
        guard let repository = sourceControlManager?.repository, let fileURL else {
            await setCommitHistory([])
            return
        }

        do {
            let commitHistory = try Array(repository.log(sorting: .time).prefix(40))
//                .gitClient
//                .getCommitHistory(
//                    maxCount: 40,
//                    fileLocalPath: fileURL,
//                    showMergeCommits: Settings.shared.preferences.sourceControl.git.showMergeCommitsPerFileLog
//                )
            await setCommitHistory(commitHistory)
        } catch {
            await setCommitHistory([])
        }
    }

    @MainActor
    private func setCommitHistory(_ history: [Commit]) {
        self.commitHistory = history
    }
}
