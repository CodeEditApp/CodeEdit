//
//  HistoryInspectorModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/18.
//

import Foundation

final class HistoryInspectorModel: ObservableObject {

    /// A GitClient instance
    private(set) var gitClient: GitClient?

    /// The base URL of the workspace
    private(set) var workspaceURL: URL?

    /// The base URL of the workspace
    private(set) var fileURL: String?

    /// The selected branch from the GitClient
    @Published
    var commitHistory: [GitCommit] = []

    func setWorkspace(url: URL?) {
        if workspaceURL != url {
            workspaceURL = url
            updateCommitHistory()
        }
    }

    func setFile(url: String?) {
        if fileURL != url {
            fileURL = url
            updateCommitHistory()
        }
    }

    func updateCommitHistory() {
        guard let workspaceURL, let fileURL else {
            commitHistory = []
            return
        }
        gitClient = GitClient(directoryURL: workspaceURL, shellClient: currentWorld.shellClient)
        do {
            let commitHistory = try gitClient?.getCommitHistory(entries: 40, fileLocalPath: fileURL)
            self.commitHistory = commitHistory ?? []
        } catch {
            commitHistory = []
        }
    }
}
