//
//  SourceControlManager+BranchOperations.swift
//  CodeEdit
//
//  Created by Austin Condiff on 7/2/24.
//

import Foundation
import CodeEditDomain

/// Branch-related git operations.
extension SourceControlManager {
    /// Refresh current branch
    func refreshCurrentBranch() async {
        let currentBranch = try? await gitClient.getCurrentBranch()
        await MainActor.run {
            self.currentBranch = currentBranch
        }
    }

    /// Refresh branches
    func refreshBranches() async {
        let branches = (try? await gitClient.getBranches(remote: nil)) ?? []
        await MainActor.run {
            self.branches = branches
        }
    }

    /// Checkout branch
    func checkoutBranch(branch: GitBranch) async throws {
        try await gitClient.checkoutBranch(branch, forceLocal: false, newName: nil)
        await refreshBranches()
        await refreshCurrentBranch()
    }

    /// Create new branch, can be created only from local branch
    func newBranch(name: String, from: GitBranch) async throws {
        try await gitClient.checkoutBranch(from, forceLocal: false, newName: name)
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
}
