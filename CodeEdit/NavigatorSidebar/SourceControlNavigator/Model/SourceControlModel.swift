//
//  SourceControlModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/05.
//

import Foundation
import Git

/// This model handle the fetching and adding of changes etc... for the
/// Source Control Navigator
public final class SourceControlModel: ObservableObject {

    /// A GitClient instance
    let gitClient: GitClient

    /// The base URL of the workspace
    let workspaceURL: URL

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
