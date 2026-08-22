//
//  HistoryInspectorModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/18.
//

import Foundation
import CodeEditSettings
import CodeEditCore

/// Main-actor isolated: it is created and driven entirely by `HistoryInspectorView`, and this
/// target compiles under Swift 6 strict concurrency, where passing a non-`Sendable` model into a
/// `Task` from the view is an error rather than the warning it was app-side.
@MainActor
final class HistoryInspectorModel: ObservableObject {
    /// The settings store. Assigned by `HistoryInspectorView` from the environment, alongside the
    /// source-control manager — this model is created by a view and configured the same way.
    var settingsAccessor: SettingsAccessing = DefaultSettingsReader()

    private(set) var sourceControlManager: SourceControlManager?

    /// The base URL of the workspace
    private(set) var workspaceURL: URL?

    /// The base URL of the workspace
    private(set) var fileURL: String?

    /// The selected branch from the GitClient
    @Published var commitHistory: [GitCommit] = []

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
        guard let sourceControlManager, let fileURL else {
            commitHistory = []
            return
        }

        do {
            let commitHistory = try await sourceControlManager
                .gitClient
                .getCommitHistory(
                    branchName: nil,
                    maxCount: 40,
                    fileLocalPath: fileURL,
                    showMergeCommits: settingsAccessor.value(SourceControlSettings.self).git.showMergeCommitsPerFileLog
                )
            self.commitHistory = commitHistory
        } catch {
            self.commitHistory = []
        }
    }
}
