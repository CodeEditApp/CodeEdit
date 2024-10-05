//
//  GitBranch.swift
//  CodeEdit
//
//  Created by Albert Vinizhanau on 10/20/23.
//

import Foundation

struct GitBranch: Hashable, Identifiable {
    let name: String
    let longName: String
    let upstream: String?
    let ahead: Int
    let behind: Int

    var id: String {
        longName
    }

    /// Is local branch
    var isLocal: Bool {
        return longName.hasPrefix("refs/heads/")
    }

    /// Is remote branch
    var isRemote: Bool {
        return longName.hasPrefix("refs/remotes/")
    }
}
