//
//  GitLabAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)

public struct GitLabAccount {
    let configuration: GitRouterConfiguration

    public init(_ config: GitRouterConfiguration = GitLabTokenConfiguration()) {
        configuration = config
    }
}
