//
//  GitBranch.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

public struct GitBranch: Hashable, Identifiable, Sendable {
    public let name: String
    public let longName: String
    public let upstream: String?
    public let ahead: Int
    public let behind: Int

    public var id: String {
        longName
    }

    /// Is local branch
    public var isLocal: Bool {
        return longName.hasPrefix("refs/heads/")
    }

    /// Is remote branch
    public var isRemote: Bool {
        return longName.hasPrefix("refs/remotes/")
    }

    public init(
        name: String,
        longName: String,
        upstream: String?,
        ahead: Int,
        behind: Int
    ) {
        self.name = name
        self.longName = longName
        self.upstream = upstream
        self.ahead = ahead
        self.behind = behind
    }
}
