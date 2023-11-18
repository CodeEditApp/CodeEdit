//
//  SourceControlModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation
import AppKit

/// This model handle the fetching and adding of changes etc... 
final class SourceControlManager: ObservableObject {
    let gitClient: GitClient

    /// The base URL of the workspace
    let workspaceURL: URL

    let editorManager: EditorManager
    weak var fileManager: CEWorkspaceFileManager?

    /// A list of changed files
    @Published var changedFiles: [CEWorkspaceFile] = []

    /// Current branch
    @Published var currentBranch: GitBranch?

    /// All branches, local and remote
    @Published var branches: [GitBranch] = []

    /// Files user selected to commit
    @Published var filesToCommit: [CEWorkspaceFile.ID] = []

    /// Number of unsynced commits with remote in current branch
    @Published var numberOfUnsyncedCommits: Int = 0

    init(
        workspaceURL: URL,
        editorManager: EditorManager
    ) {
        self.workspaceURL = workspaceURL
        self.editorManager = editorManager
        gitClient = GitClient(directoryURL: workspaceURL, shellClient: currentWorld.shellClient)
    }

    /// Refresh all changed files and refresh status in file manager
    func refresAllChangesFiles() async {
        do {
            var changedFiles: [CEWorkspaceFile] = []

            for item in try await gitClient.getChangedFiles() {
                changedFiles.append(.init(url: item.fileLink, changeType: item.changeType))
            }

            await setChangedFiles(changedFiles)
            await refreshStatusInFileManager()
        } catch {
            await setChangedFiles([])
        }
    }

    /// Set changed files on main actor
    @MainActor
    private func setChangedFiles(_ files: [CEWorkspaceFile]) {
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
            guard let file = fileManager.flattenedFileItems[changedFile.id] else {
                continue
            }
            if file.gitStatus != changedFile.gitStatus {
                file.gitStatus = changedFile.gitStatus
                updatedStatusFor.insert(file)
            }
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
        if !from.isLocal {
            return
        }

        try await gitClient.newBranch(name: name, from: from)
        await refreshBranches()
        await refreshCurrentBranch()
    }

    /// Delete branch if it's local and not current
    func deleteBranch(branch: GitBranch) async throws {
        if !branch.isLocal || branch == currentBranch {
            return
        }

        try await gitClient.deleteBranch(branch)
        await refreshBranches()
    }

    /// Discard changes for file
    func discardChanges(for file: CEWorkspaceFile) {
        Task {
            do {
                try await gitClient.discardChanges(for: file.url)
                // TODO: Refresh content of active and unmodified document,
                // requires CodeEditTextView changes
            } catch {
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
                // requires CodeEditTextView changes
            } catch {
                await showAlertForError(title: "Failed to discard changes", error: error)
            }
        }
    }

    /// Commit files selected by user
    func commit(message: String) async throws {
        var filesToCommit: [CEWorkspaceFile] = []
        for file in changedFiles where self.filesToCommit.contains(file.id) {
            filesToCommit.append(file)
        }

        if filesToCommit.isEmpty {
            return
        }

        try await gitClient.commit(filesToCommit, message: message)

        await MainActor.run {
            self.filesToCommit = []
        }

        await self.refresAllChangesFiles()
        await self.refreshNumberOfUnsyncedCommits()
    }

    /// Refresh number of unsynced commits
    func refreshNumberOfUnsyncedCommits() async {
        let numberOfUnsyncedCommits = (try? await gitClient.numberOfUnsyncedCommits()) ?? 0

        await MainActor.run {
            self.numberOfUnsyncedCommits = numberOfUnsyncedCommits
        }
    }

    /// Push changes to remote
    func push() async throws {
        guard let currentBranch else { return }

        if currentBranch.upstream == nil {
            try await gitClient.pushToRemote(upstream: currentBranch.name)
            await refreshCurrentBranch()
        } else {
            try await gitClient.pushToRemote()
        }

        await self.refreshNumberOfUnsyncedCommits()
    }

    /// Show alert for error
    func showAlertForError(title: String, error: Error) async {
        if let error = error as? GitClient.GitClientError {
            await showAlert(title: title, message: error.description)
            return
        }

        await showAlert(title: title, message: error.localizedDescription)
    }

    private func showAlert(title: String, message: String) async {
        await MainActor.run {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
}
