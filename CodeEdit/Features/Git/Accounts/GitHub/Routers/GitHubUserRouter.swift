//
//  GitHubUserRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanshi Li on 2022/03/31.
//

import Foundation

enum GitHubUserRouter: GitRouter {
    case readAuthenticatedUser(GitRouterConfiguration)
    case readUser(String, GitRouterConfiguration)

    var configuration: GitRouterConfiguration? {
        switch self {
        case let .readAuthenticatedUser(config): return config
        case let .readUser(_, config): return config
        }
    }

    var method: GitHTTPMethod {
        .GET
    }

    var encoding: GitHTTPEncoding {
        .url
    }

    var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case let .readUser(username, _):
            return "users/\(username)"
        }
    }

    var params: [String: Any] {
        [:]
    }
}
