//
//  GithubAccount.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public let githubBaseURL = "https://api.github.com"
public let githubWebURL = "https://github.com"

public struct GithubAccount {
    public let configuration: GithubTokenConfiguration

    public init(_ config: GithubTokenConfiguration = GithubTokenConfiguration()) {
        configuration = config
    }
}
