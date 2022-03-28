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
    public var getCommitHistory: (_ entries: Int?) throws -> [Commit]

    init(
        getCurrentBranchName: @escaping () throws -> String,
        getBranches: @escaping () throws -> [String],
        checkoutBranch: @escaping (String) throws -> Void,
        pull: @escaping () throws -> Void,
        cloneRepository: @escaping (String) throws -> Void,
        getCommitHistory: @escaping (_ entries: Int?) throws -> [Commit]
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
