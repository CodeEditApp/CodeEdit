//
//  ChangesModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/05.
//

import Foundation
import Git

public final class ChangesModel: ObservableObject {

    /// A GitClient instance
    private(set) var gitClient: GitClient

    /// The base URL of the workspace
    private(set) var workspaceURL: URL

    /// A list of changed files
    @Published
    public var changed: [ChangedFiles]

    /// Initialize with a GitClient
    /// - Parameter workspaceURL: the current workspace URL
    ///
    public init(workspaceURL: URL) {
        self.workspaceURL = workspaceURL
        gitClient = GitClient.default(
            directoryURL: workspaceURL,
            shellClient: Current.shellClient
        )
        do {
            let changed = try gitClient.getChangedFiles()
            self.changed = changed
        } catch {
            changed = []
        }
    }
}
