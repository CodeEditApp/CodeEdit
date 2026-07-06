//
//  SourceControlManager+FileOperations.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/2/24.
//

import Foundation
import CodeEditCore

/// File status, staging, committing, and discard operations.
extension SourceControlManager {
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

    /// Publish the current git status snapshot for the workspace's files. The
    /// file manager applies these statuses onto its cached files.
    @MainActor
    private func refreshStatusInFileManager() {
        let changed = Dictionary(
            changedFiles.map { ($0.ceFileKey, $0.anyStatus()) },
            uniquingKeysWith: { _, latest in latest }
        )
        eventBus.publish(GitStatusChangedEvent(workspaceURL: workspaceURL, changed: changed))
    }
}
