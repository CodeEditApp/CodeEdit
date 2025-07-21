//
//  SourceControlManager+GitClient.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/2/24.
//

import Foundation

extension SourceControlManager {
    /// Validate repository
    func validate() async throws {
        let isGitRepository = await gitClient.validate()
        await MainActor.run {
            self.isGitRepository = isGitRepository
        }
    }

    /// Fetch from remote
    func fetch() async throws {
        try await gitClient.fetchFromRemote()
        await self.refreshNumberOfUnsyncedCommits()
    }

    /// Refresh current branch
    func refreshCurrentBranch() async {
        let currentBranch = try? await gitClient.getCurrentBranch()
        await MainActor.run {
            self.currentBranch = currentBranch
        }
    }

    /// Refresh branches
    func refreshBranches() async {
        let branches = (try? await gitClient.getBranches()) ?? []
        await MainActor.run {
            self.branches = branches
        }
    }

    /// Checkout branch
    func checkoutBranch(branch: GitBranch) async throws {
        try await gitClient.checkoutBranch(branch)
        await refreshBranches()
        await refreshCurrentBranch()
    }

    /// Create new branch, can be created only from local branch
    func newBranch(name: String, from: GitBranch) async throws {
        try await gitClient.checkoutBranch(from, newName: name)
        await refreshBranches()
        await refreshCurrentBranch()
    }

    /// Rename branch
    func renameBranch(oldName: String, newName: String) async throws {
        try await gitClient.renameBranch(oldName: oldName, newName: newName)
        await refreshBranches()
    }

    /// Delete branch if it's local and not current
    func deleteBranch(branch: GitBranch) async throws {
        if !branch.isLocal || branch == currentBranch {
            return
        }

        try await gitClient.deleteBranch(branch)
        await refreshBranches()
    }

    /// Delete stash entry
    func deleteStashEntry(stashEntry: GitStashEntry) async throws {
        try await gitClient.deleteStashEntry(stashEntry.index)
        try await refreshStashEntries()
    }

    /// Apply stash entry
    func applyStashEntry(stashEntry: GitStashEntry) async throws {
        try await gitClient.applyStashEntry(stashEntry.index)
        try await refreshStashEntries()
        await refreshAllChangedFiles()
    }

    /// Stash changes
    func stashChanges(message: String?) async throws {
        try await gitClient.stash(message: message)
        try await refreshStashEntries()
        await refreshAllChangedFiles()
    }

    /// Delete remote
    func deleteRemote(remote: GitRemote) async throws {
        try await gitClient.removeRemote(name: remote.name)
        try await refreshRemotes()
    }

    /// Discard changes for file
    func discardChanges(for file: URL) {
        Task {
            do {
                try await gitClient.discardChanges(for: file)
                // TODO: Refresh content of active and unmodified document,
                // requires CodeEditSourceEditor changes
            } catch {
                logger.error("Failed to discard changes for file (\(file.lastPathComponent): \(error)")
                await showAlertForError(title: "Failed to discard changes", error: error)
            }
        }
    }

    /// Discard changes for repository
    func discardAllChanges() {
        Task {
            do {
                try await gitClient.discardAllChanges()
                // TODO: Refresh content of active and unmodified document,
                // requires CodeEditSourceEditor changes
            } catch {
                logger.error("Failed to discard changes: \(error)")
                await showAlertForError(title: "Failed to discard changes", error: error)
            }
        }
    }

    /// Set changed files on main actor
    @MainActor
    private func setChangedFiles(_ files: [GitChangedFile]) {
        self.changedFiles = files
    }

    /// Refresh git status for files in project navigator
    @MainActor
    private func refreshStatusInFileManager() {
        guard let fileManager = fileManager else {
            return
        }

        var updatedStatusFor: Set<CEWorkspaceFile> = []
        // Refresh status of file manager files
        for changedFile in changedFiles {
            guard let file = fileManager.getFile(changedFile.ceFileKey) else {
                continue
            }
            if file.gitStatus != changedFile.anyStatus() {
                file.gitStatus = changedFile.anyStatus()
            }
            updatedStatusFor.insert(file)
        }

        for (_, file) in fileManager.flattenedFileItems
        where !updatedStatusFor.contains(file) && file.gitStatus != nil {
            file.gitStatus = nil
            updatedStatusFor.insert(file)
        }

        if updatedStatusFor.isEmpty {
            return
        }

        fileManager.notifyObservers(updatedItems: updatedStatusFor)
    }

    /// Refresh all changed files and refresh status in file manager
    func refreshAllChangedFiles() async {
        do {
            let status = try await gitClient.getStatus()

            // TODO: Unmerged changes
            // status.unmergedChanges

            await setChangedFiles(status.changedFiles + status.untrackedFiles)
            await refreshStatusInFileManager()
        } catch GitClient.GitClientError.notGitRepository {
            await setChangedFiles([])
        } catch {
            logger.error("Error fetching git status: \(error)")
            await setChangedFiles([])
        }
    }

    /// Get all changed files for a commit
    func getCommitChangedFiles(commitSHA: String) async -> [GitChangedFile] {
        do {
            return try await gitClient.getCommitChangedFiles(commitSHA: commitSHA)
        } catch {
            logger.error("Error committing changed files: \(error)")
            return []
        }
    }

    /// Commit files selected by user
    func commit(message: String, details: String? = nil) async throws {
        try await gitClient.commit(message: message, details: details)

        await self.refreshAllChangedFiles()
        await self.refreshNumberOfUnsyncedCommits()
    }

    /// Adds the given URLs to the staged changes.
    /// - Parameter files: The files to stage.
    func add(_ files: [URL]) async throws {
        try await gitClient.add(files)
    }

    /// Removes the given URLs from the staged changes.
    /// - Parameter files: The URLs to un-stage.
    func reset(_ files: [URL]) async throws {
        try await gitClient.reset(files)
    }

    /// Refresh number of unsynced commits
    func refreshNumberOfUnsyncedCommits() async {
        let numberOfUnpushedCommits = (try? await gitClient.numberOfUnsyncedCommits()) ?? (ahead: 0, behind: 0)

        await MainActor.run {
            self.numberOfUnsyncedCommits = numberOfUnpushedCommits
        }
    }

    /// Add existing remote to git
    func addRemote(name: String, location: String) async throws {
        try await gitClient.addRemote(name: name, location: location)
        try await refreshRemotes()
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

    func refreshStashEntries() async throws {
        let stashEntries = (try? await gitClient.stashList()) ?? []
        await MainActor.run {
            self.stashEntries = stashEntries
        }
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

    /// Initiate repository
    func initiate() async throws {
        try await gitClient.initiate()
    }
}
