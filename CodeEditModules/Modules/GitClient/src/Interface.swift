//
//  File.swift
//
//
//  Created by Marco Carnevali on 21/03/22.
//

import Foundation

public struct GitClient {
    public var getCurrentBranchName: () throws -> String
    public var getBranches: () throws -> [String]
    public var checkoutBranch: (String) throws -> Void
    public var pull: () throws -> Void
    public var cloneRepository: (String) throws -> Void
    /// Get commit history
    /// - Parameters:
    ///   - entries: number of commits we want to fetch. Will use max if nil
    ///   - fileLocalPath: specify a local file (e.g. `CodeEditModules/Package.swift`)
    ///   to retrieve a file commit history. Optional.
    public var getCommitHistory: (_ entries: Int?, _ fileLocalPath: String?) throws -> [Commit]

    init(
        getCurrentBranchName: @escaping () throws -> String,
        getBranches: @escaping () throws -> [String],
        checkoutBranch: @escaping (String) throws -> Void,
        pull: @escaping () throws -> Void,
        cloneRepository: @escaping (String) throws -> Void,
        getCommitHistory: @escaping (_ entries: Int?, _ fileLocalPath: String?) throws -> [Commit]
    ) {
        self.getCurrentBranchName = getCurrentBranchName
        self.getBranches = getBranches
        self.checkoutBranch = checkoutBranch
        self.pull = pull
        self.cloneRepository = cloneRepository
        self.getCommitHistory = getCommitHistory
    }

    public enum GitClientError: Error {
        case outputError(String)
        case notGitRepository
    }
}
