//
//  File.swift
//  
//
//  Created by Marco Carnevali on 21/03/22.
//

import Foundation

public struct GitClient {
    public var getCurrentBranchName: () -> String
    public var getBranches: () -> [String]
    public var checkoutBranch: (String) throws -> Void
    public var pull: () -> Void
    public var cloneRepository: (String) throws -> Void

    init(
        getCurrentBranchName: @escaping () -> String,
        getBranches: @escaping () -> [String],
        checkoutBranch: @escaping (String) throws -> Void,
        pull: @escaping () -> Void,
        cloneRepository: @escaping (String) throws -> Void
    ) {
        self.getCurrentBranchName = getCurrentBranchName
        self.getBranches = getBranches
        self.checkoutBranch = checkoutBranch
        self.pull = pull
        self.cloneRepository = cloneRepository
    }

    public enum GitClientError: Error {
        case outputError(String)
    }
}
