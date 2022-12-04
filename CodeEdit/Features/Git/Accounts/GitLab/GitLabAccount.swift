//
//  GitLabAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)

struct GitLabAccount {
    let configuration: GitRouterConfiguration

    init(_ config: GitRouterConfiguration = GitLabTokenConfiguration()) {
        configuration = config
    }
}
