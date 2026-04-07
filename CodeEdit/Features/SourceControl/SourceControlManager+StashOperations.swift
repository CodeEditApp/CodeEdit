//
//  SourceControlManager+StashOperations.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/2/24.
//

import Foundation

/// Stash-related git operations.
extension SourceControlManager {
    /// Refresh stash entries
    func refreshStashEntries() async throws {
        let stashEntries = (try? await gitClient.stashList()) ?? []
        await MainActor.run {
            self.stashEntries = stashEntries
        }
    }

    /// Stash changes
    func stashChanges(message: String?) async throws {
        try await gitClient.stash(message: message)
        try await refreshStashEntries()
        await refreshAllChangedFiles()
    }

    /// Apply stash entry
    func applyStashEntry(stashEntry: GitStashEntry) async throws {
        try await gitClient.applyStashEntry(stashEntry.index)
        try await refreshStashEntries()
        await refreshAllChangedFiles()
    }

    /// Delete stash entry
    func deleteStashEntry(stashEntry: GitStashEntry) async throws {
        try await gitClient.deleteStashEntry(stashEntry.index)
        try await refreshStashEntries()
    }
}
