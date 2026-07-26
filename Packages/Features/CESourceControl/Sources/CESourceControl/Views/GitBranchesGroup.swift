//
//  GitBranchesGroup.swift
//  CodeEdit
//
//  Created by Federico Zivolo on 22/01/24.
//

import Foundation
import CodeEditCore

public struct GitBranchesGroup: Hashable, Sendable {
    public let name: String
    public var branches: [GitBranch]
    public var shouldNest: Bool {
        branches.first?.name.hasPrefix(name + "/") ?? false
    }

    public init(
        name: String,
        branches: [GitBranch]
    ) {
        self.name = name
        self.branches = branches
    }
}
