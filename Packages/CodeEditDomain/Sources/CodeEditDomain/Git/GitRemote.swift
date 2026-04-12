//
//  GitRemote.swift
//  CodeEdit
//
//  Created by Austin Condiff on 11/17/23.
//

import Foundation

public struct GitRemote: Hashable {
    public let name: String
    public let pushLocation: String
    public let fetchLocation: String
    public var branches: [GitBranch]

    public init(
        name: String,
        pushLocation: String,
        fetchLocation: String,
        branches: [GitBranch] = []
    ) {
        self.name = name
        self.pushLocation = pushLocation
        self.fetchLocation = fetchLocation
        self.branches = branches
    }
}
