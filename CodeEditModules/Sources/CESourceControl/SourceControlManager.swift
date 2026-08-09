//
//  SourceControlModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import Combine
import Foundation
import OSLog
import CodeEditCore
import CodeEditSettings

/// Stores git state for the workspace and delegates operations to ``GitClient``.
///
/// Git operations are organized across domain-specific extensions:
/// - `+BranchOperations`: checkout, create, rename, delete branches
/// - `+StashOperations`: stash, apply, delete stash entries
/// - `+RemoteOperations`: fetch, pull, push, remote management
/// - `+FileOperations`: status, staging, commit, discard
/// - `+Repository`: validate, initiate
/// - `+Alerts`: error presentation helpers
@MainActor
public final class SourceControlManager: ObservableObject {
    public let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "SourceControlManager")

    public let gitClient: GitClientProtocol

    /// Reads git configuration. Exposed so source-control views can consult config
    /// (e.g. `pull.rebase`) without their own shell-client plumbing.
    public let gitConfig: GitConfigClient

    /// The base URL of the workspace
    public let workspaceURL: URL

    let eventBus: EventBus
    let settingsReader: SettingsReading
    var fileEventCancellables: Set<AnyCancellable> = []

    // MARK: - Git State

    /// A list of changed files
    @Published public var changedFiles: [GitChangedFile] = []

    /// Current branch
    @Published public var currentBranch: GitBranch?

    /// All branches, local and remote
    @Published public var branches: [GitBranch] = []

    /// All remotes
    @Published public var remotes: [GitRemote] = []

    /// All stashed entries
    @Published public var stashEntries: [GitStashEntry] = []

    /// Number of unsynced commits with remote in current branch
    @Published public var numberOfUnsyncedCommits: (ahead: Int, behind: Int) = (ahead: 0, behind: 0)

    /// Is project a git repository
    @Published public var isGitRepository: Bool = false

    // MARK: - Computed Properties

    public var orderedLocalBranches: [GitBranch] {
        var orderedBranches: [GitBranch] = [currentBranch].compactMap { $0 }
        let otherBranches = branches.filter { $0.isLocal && $0 != currentBranch }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
        orderedBranches.append(contentsOf: otherBranches)
        return orderedBranches
    }

    // MARK: - Initialization

    public init(
        workspaceURL: URL,
        shellClient: ShellClientProtocol,
        eventBus: EventBus,
        settingsReader: SettingsReading
    ) {
        self.workspaceURL = workspaceURL
        self.eventBus = eventBus
        self.settingsReader = settingsReader
        gitClient = GitClient(directoryURL: workspaceURL, shellClient: shellClient)
        gitConfig = GitConfigClient(shellClient: shellClient)
        subscribeToWorkspaceFileEvents()
        Task { try? await validate() }
    }
}
