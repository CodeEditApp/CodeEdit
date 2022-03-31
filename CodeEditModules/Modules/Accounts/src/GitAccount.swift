//
//  GitAccount.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public let bitbucketBaseURL = "https://api.bitbucket.org/2.0"
public let bitbucketWebURL = "https://bitbucket.org/"

public let gitlabBaseURL = "https://gitlab.com/api/v4/"
public let gitlabWebURL = "https://gitlab.com/"

public let githubBaseURL = "https://api.github.com"
public let githubWebURL = "https://github.com"

public struct GitAccount {
    public let configuration: TokenConfiguration

    public init(_ config: TokenConfiguration = TokenConfiguration()) {
        configuration = config
    }
}
