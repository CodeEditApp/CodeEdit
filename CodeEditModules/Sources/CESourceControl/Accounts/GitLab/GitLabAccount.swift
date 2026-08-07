//
//  GitLabAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)

/// Entry point for GitLab API requests, bound to the configuration of a signed-in (or anonymous) account.
public struct GitLabAccount {
    let configuration: GitRouterConfiguration

    /// Creates an account using the given router configuration; defaults to an unauthenticated `gitlab.com` setup.
    public init(_ config: GitRouterConfiguration = GitLabTokenConfiguration()) {
        configuration = config
    }
}
