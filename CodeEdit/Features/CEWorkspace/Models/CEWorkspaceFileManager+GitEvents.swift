//
//  CEWorkspaceFileManager+GitEvents.swift
//  CodeEdit
//
//  Created by Axel Martinez on 5/8/24.
//

import Foundation

/// Handles git-specific file system events by detecting changes to git internals
/// and dispatching targeted refreshes to `SourceControlManager`.
extension CEWorkspaceFileManager {
    func handleGitEvents(events: [DirectoryEventStream.Event]) {
        refreshChangedFilesIfNeeded(events: events)
        refreshStashIfNeeded(events: events)
        refreshBranchesIfNeeded(events: events)
        refreshCurrentBranchIfNeeded(events: events)
        refreshRemotesIfNeeded(events: events)
        validateRepositoryIfNeeded(events: events)
    }

    /// If changes were made to project files or the git index, refresh the changed files list.
    private func refreshChangedFilesIfNeeded(events: [DirectoryEventStream.Event]) {
        let hasNonGitChanges = events.contains(where: { !$0.path.contains(".git/") })
        let hasIndexChange = events.contains(where: {
            $0.path == "\(self.folderUrl.relativePath)/.git/index"
        })

        guard hasNonGitChanges || hasIndexChange else { return }
        Task {
            await self.sourceControlManager?.refreshAllChangedFiles()
        }
    }

    /// If changes were stashed, refresh stash entries.
    private func refreshStashIfNeeded(events: [DirectoryEventStream.Event]) {
        guard events.contains(where: {
            $0.path == "\(self.folderUrl.relativePath)/.git/refs/stash"
        }) else { return }
        Task {
            try await self.sourceControlManager?.refreshStashEntries()
        }
    }

    /// If branches were added or removed, refresh the branches list.
    private func refreshBranchesIfNeeded(events: [DirectoryEventStream.Event]) {
        guard events.contains(where: {
            $0.path.contains("\(self.folderUrl.relativePath)/.git/refs/heads")
        }) else { return }
        Task {
            await self.sourceControlManager?.refreshBranches()
        }
    }

    /// If HEAD was changed, refresh the current branch.
    private func refreshCurrentBranchIfNeeded(events: [DirectoryEventStream.Event]) {
        guard events.contains(where: {
            $0.path.contains("\(self.folderUrl.relativePath)/.git/HEAD")
        }) else { return }
        Task {
            await self.sourceControlManager?.refreshCurrentBranch()
        }
    }

    /// If .git/config changed, refresh remotes.
    private func refreshRemotesIfNeeded(events: [DirectoryEventStream.Event]) {
        guard events.contains(where: {
            $0.path == "\(self.folderUrl.relativePath)/.git/config"
        }) else { return }
        Task {
            try await self.sourceControlManager?.refreshRemotes()
        }
    }

    /// If the .git folder was added or removed, validate the repository.
    private func validateRepositoryIfNeeded(events: [DirectoryEventStream.Event]) {
        guard events.contains(where: {
            $0.path == "\(self.folderUrl.relativePath)/.git"
        }) else { return }
        Task {
            try await self.sourceControlManager?.validate()
        }
    }
}
