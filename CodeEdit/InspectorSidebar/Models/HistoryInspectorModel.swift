//
//  HistoryInspectorModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/04/18.
//

import Foundation

final class HistoryInspectorModel: ObservableObject {

    /// A GitClient instance
    private(set) var gitClient: GitClient

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// The base URL of the workspace
    private(set) var fileURL: String

    /// The selected branch from the GitClient
    @Published
    var commitHistory: [Commit]

    /// Initialize with a GitClient
    /// - Parameter workspaceURL: the current workspace URL
    ///
    init(workspaceURL: URL, fileURL: String) {
        self.workspaceURL = workspaceURL
        self.fileURL = fileURL
        gitClient = GitClient(directoryURL: workspaceURL, shellClient: Current.shellClient)
        do {
            let commitHistory = try gitClient.getCommitHistory(entries: 40, fileLocalPath: fileURL)
            self.commitHistory = commitHistory
        } catch {
            commitHistory = []
        }
    }
}
