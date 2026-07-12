//
//  GitClientProtocol.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07.04.26.
//

import Foundation
import CodeEditCore

/// Abstraction over git operations used by ``SourceControlManager``.
///
/// This protocol decouples the manager from the concrete ``GitClient`` class,
/// enabling mock-based testing without hitting the shell.
/// `Sendable`: implementations must be stateless command executors (the concrete
/// `GitClient` holds only immutable `let` configuration), so they may be used from
/// any concurrency domain.
public protocol GitClientProtocol: Sendable {
    // MARK: - Repository

    func validate() async -> Bool
    func initiate() async throws

    // MARK: - Branches

    func getBranches(remote: String?) async throws -> [GitBranch]
    func getCurrentBranch() async throws -> GitBranch?
    func checkoutBranch(_ branch: GitBranch, forceLocal: Bool, newName: String?) async throws
    func renameBranch(oldName: String, newName: String) async throws
    func deleteBranch(_ branch: GitBranch) async throws

    // MARK: - Stash

    func stash(message: String?) async throws
    func stashList() async throws -> [GitStashEntry]
    func applyStashEntry(_ index: Int?) async throws
    func deleteStashEntry(_ index: Int) async throws

    // MARK: - History

    func getCommitHistory(
        branchName: String?,
        maxCount: Int?,
        fileLocalPath: String?,
        showMergeCommits: Bool
    ) async throws -> [GitCommit]

    // MARK: - Status & Files

    func getStatus() async throws -> GitClient.Status
    func commit(message: String, details: String?) async throws
    func add(_ files: [URL]) async throws
    func reset(_ files: [URL]) async throws
    func numberOfUnsyncedCommits() async throws -> (ahead: Int, behind: Int)
    func getCommitChangedFiles(commitSHA: String) async throws -> [GitChangedFile]
    func discardChanges(for file: URL) async throws
    func discardAllChanges() async throws

    // MARK: - Remotes

    func getRemotes() async throws -> [GitRemote]
    func addRemote(name: String, location: String) async throws
    func removeRemote(name: String) async throws
    func fetchFromRemote() async throws
    func pullFromRemote(remote: String?, branch: String?, rebase: Bool) async throws
    func pushToRemote(remote: String?, branch: String?, setUpstream: Bool?, force: Bool?, tags: Bool?) async throws
}
