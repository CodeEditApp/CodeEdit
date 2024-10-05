//
//  SourceControlModel.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import Foundation
import AppKit
import OSLog

/// This class is used to perform git functions such as fetch, pull, add/remove of changes, commit, push, etc.
/// It also stores remotes, branches, current changes, stashes, and commits
final class SourceControlManager: ObservableObject {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "SourceControlManager")

    let gitClient: GitClient

    /// The base URL of the workspace
    let workspaceURL: URL

    let editorManager: EditorManager
    weak var fileManager: CEWorkspaceFileManager?

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

    /// Is the push sheet presented
    @Published var pushSheetIsPresented: Bool = false {
        didSet {
            self.operationBranch = nil
            self.operationRebase = false
            self.operationForce = false
            self.operationIncludeTags = false
        }
    }

    /// Is the pull sheet presented
    @Published var pullSheetIsPresented: Bool = false {
        didSet {
            self.operationBranch = nil
            self.operationRebase = false
            self.operationForce = false
            self.operationIncludeTags = false
        }
    }

    /// Is the fetch sheet presented
    @Published var fetchSheetIsPresented: Bool = false

    /// Is the stash sheet presented
    @Published var stashSheetIsPresented: Bool = false

    /// Is the remote sheet presented
    @Published var addExistingRemoteSheetIsPresented: Bool = false

    /// Branch selected for source control operations
    @Published var operationBranch: GitBranch?

    /// Remote selected for source control operations
    @Published var operationRemote: GitRemote?

    /// Rebase boolean set for source control operations
    @Published var operationRebase: Bool = false

    /// Force boolean set for source control operations
    @Published var operationForce: Bool = false

    /// Include tags boolean set for source control operations
    @Published var operationIncludeTags: Bool = false

    /// Branch to switch to
    @Published var switchToBranch: GitBranch?

    /// Is discard all alert presented
    @Published var discardAllAlertIsPresented: Bool = false

    /// Is no changes to stage alert presented
    @Published var noChangesToStageAlertIsPresented: Bool = false

    /// Is no changes to unstage alert presented
    @Published var noChangesToUnstageAlertIsPresented: Bool = false

    /// Is no changes to stash alert presented
    @Published var noChangesToStashAlertIsPresented: Bool = false

    /// Is no changes to discard alert presented
    @Published var noChangesToDiscardAlertIsPresented: Bool = false

    var orderedLocalBranches: [GitBranch] {
        var orderedBranches: [GitBranch] = [currentBranch].compactMap { $0 }
        let otherBranches = branches.filter { $0.isLocal && $0 != currentBranch }
            .sorted { $0.name.lowercased() < $1.name.lowercased() }
        orderedBranches.append(contentsOf: otherBranches)
        return orderedBranches
    }

    init(
        workspaceURL: URL,
        editorManager: EditorManager
    ) {
        self.workspaceURL = workspaceURL
        self.editorManager = editorManager
        gitClient = GitClient(directoryURL: workspaceURL, shellClient: currentWorld.shellClient)
    }

    /// Show alert for error
    func showAlertForError(title: String, error: Error) async {
        if let error = error as? GitClient.GitClientError {
            await showAlert(title: title, message: error.description)
            return
        }

        if let error = error as? LocalizedError {
            var description = error.errorDescription ?? ""
            if let failureReason = error.failureReason {
                if description.isEmpty {
                    description += failureReason
                } else {
                    description += "\n\n" + failureReason
                }
            }

            if let recoverySuggestion = error.recoverySuggestion {
                if description.isEmpty {
                    description += recoverySuggestion
                } else {
                    description += "\n\n" + recoverySuggestion
                }
            }

            await showAlert(title: title, message: description)
        } else {
            await showAlert(title: title, message: error.localizedDescription)
        }
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
