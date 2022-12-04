//
//  Parameters.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum GitSortDirection: String {
    case asc
    case desc
}

enum GitSortType: String {
    case created
    case updated
    case popularity
    case longRunning = "long-running"
}

enum GitURL {
    static let bitbucketBaseURL = "https://api.bitbucket.org/2.0"
    static let bitbucketWebURL = "https://bitbucket.org/"
    static let githubBaseURL = "https://api.github.com"
    static let githubWebURL = "https://github.com"
    static let gitlabBaseURL = "https://gitlab.com/api/v4/"
    static let gitlabWebURL = "https://gitlab.com/"
}
