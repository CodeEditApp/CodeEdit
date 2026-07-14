//
//  GitHubAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)

/// Entry point for GitHub API requests, bound to the configuration of a signed-in (or anonymous) account.
public struct GitHubAccount {
    let configuration: GitHubTokenConfiguration

    /// Creates an account using the given token configuration; defaults to an unauthenticated `github.com` setup.
    public init(_ config: GitHubTokenConfiguration = GitHubTokenConfiguration()) {
        configuration = config
    }
}
