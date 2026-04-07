//
//  SourceControlManager+RemoteOperations.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/2/24.
//

import Foundation

/// Remote, fetch, pull, and push operations.
extension SourceControlManager {
    /// Fetch from remote
    func fetch() async throws {
        try await gitClient.fetchFromRemote()
        await self.refreshNumberOfUnsyncedCommits()
    }

    /// Pull changes from remote
    func pull(remote: String? = nil, branch: String? = nil, rebase: Bool = false) async throws {
        try await gitClient.pullFromRemote(remote: remote, branch: branch, rebase: rebase)
        await self.refreshNumberOfUnsyncedCommits()
    }

    /// Push changes to remote
    func push(
        remote: String? = nil,
        branch: String? = nil,
        setUpstream: Bool = false,
        force: Bool = false,
        tags: Bool = false
    ) async throws {
        guard currentBranch != nil else { return }

        try await gitClient.pushToRemote(
            remote: remote,
            branch: branch,
            setUpstream: setUpstream,
            force: force,
            tags: tags
        )

        await refreshCurrentBranch()
        await self.refreshNumberOfUnsyncedCommits()
    }

    /// Get all remotes
    func refreshRemotes() async throws {
        let remotes = (try? await gitClient.getRemotes()) ?? []
        await MainActor.run {
            self.remotes = remotes
        }
        if !remotes.isEmpty {
            try await self.refreshAllRemotesBranches()
        }
    }

    /// Refresh branches for all remotes
    func refreshAllRemotesBranches() async throws {
        for remote in remotes {
            try await refreshRemoteBranches(remote: remote)
        }
    }

    /// Refresh branches for a specific remote
    func refreshRemoteBranches(remote: GitRemote) async throws {
        let branches = try await getRemoteBranches(remote: remote.name)
        if let index = remotes.firstIndex(of: remote) {
            await MainActor.run {
                remotes[index].branches = branches
            }
        }
    }

    /// Get branches for a specific remote
    func getRemoteBranches(remote: String) async throws -> [GitBranch] {
        try await gitClient.getBranches(remote: remote)
    }

    /// Add existing remote to git
    func addRemote(name: String, location: String) async throws {
        try await gitClient.addRemote(name: name, location: location)
        try await refreshRemotes()
    }

    /// Delete remote
    func deleteRemote(remote: GitRemote) async throws {
        try await gitClient.removeRemote(name: remote.name)
        try await refreshRemotes()
    }
}
