//
//  SourceControlModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation
import OSLog
import CodeEditCore

/// Stores git state for the workspace and delegates operations to ``GitClient``.
///
/// Git operations are organized across domain-specific extensions:
/// - `+BranchOperations`: checkout, create, rename, delete branches
/// - `+StashOperations`: stash, apply, delete stash entries
/// - `+RemoteOperations`: fetch, pull, push, remote management
/// - `+FileOperations`: status, staging, commit, discard
/// - `+Repository`: validate, initiate
/// - `+Alerts`: error presentation helpers
final class SourceControlManager: ObservableObject {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "SourceControlManager")

    let gitClient: GitClientProtocol

    /// The base URL of the workspace
    let workspaceURL: URL

    weak var fileManager: CEWorkspaceFileManager?

    // MARK: - Git State

    /// A list of changed files
    @Published var changedFiles: [GitChangedFile] = []

    /// Current branch
    @Published var currentBranch: GitBranch?

    /// All branches, local and remote
    @Published var branches: [GitBranch] = []

    /// All remotes
    @Published var remotes: [GitRemote] = []

    /// All stashed entries
    @Published var stashEntries: [GitStashEntry] = []

    /// Number of unsynced commits with remote in current branch
    @Published var numberOfUnsyncedCommits: (ahead: Int, behind: Int) = (ahead: 0, behind: 0)

    /// Is project a git repository
    @Published var isGitRepository: Bool = false

    // MARK: - Computed Properties

    var orderedLocalBranches: [GitBranch] {
        var orderedBranches: [GitBranch] = [currentBranch].compactMap { $0 }
        let otherBranches = branches.filter { $0.isLocal && $0 != currentBranch }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
        orderedBranches.append(contentsOf: otherBranches)
        return orderedBranches
    }

    // MARK: - Initialization

    init(
        workspaceURL: URL,
        shellClient: ShellClientProtocol
    ) {
        self.workspaceURL = workspaceURL
        gitClient = GitClient(directoryURL: workspaceURL, shellClient: shellClient)
    }
}
