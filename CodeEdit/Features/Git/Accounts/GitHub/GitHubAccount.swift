//
//  GitHubAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)

let githubBaseURL = "https://api.github.com"
let githubWebURL = "https://github.com"

struct GitHubAccount {
    let configuration: GitHubTokenConfiguration

    init(_ config: GitHubTokenConfiguration = GitHubTokenConfiguration()) {
        configuration = config
    }
}
