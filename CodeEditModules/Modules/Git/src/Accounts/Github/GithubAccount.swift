//
//  GithubAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
// swiftlint:disable missing_docs

public let githubBaseURL = "https://api.github.com"
public let githubWebURL = "https://github.com"

public struct GithubAccount {
    public let configuration: GithubTokenConfiguration

    public init(_ config: GithubTokenConfiguration = GithubTokenConfiguration()) {
        configuration = config
    }
}
