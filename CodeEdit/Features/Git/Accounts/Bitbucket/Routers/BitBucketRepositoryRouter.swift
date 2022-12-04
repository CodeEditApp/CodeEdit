//
//  BitBucketRepositoryRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum BitBucketRepositoryRouter: GitRouter {
    case readRepositories(GitRouterConfiguration, String?, [String: String])
    case readRepository(GitRouterConfiguration, String, String)

    var configuration: GitRouterConfiguration? {
        switch self {
        case .readRepositories(let config, _, _): return config
        case .readRepository(let config, _, _): return config
        }
    }

    var method: GitHTTPMethod {
        .GET
    }

    var encoding: GitHTTPEncoding {
        .url
    }

    var params: [String: Any] {
        switch self {
        case .readRepositories(_, let userName, var nextParameters):
            if userName != nil {
                return nextParameters as [String: Any]
            } else {
                nextParameters["role"] = "member"
                return nextParameters as [String: Any]
            }
        case .readRepository:
            return [:]
        }
    }

    var path: String {
        switch self {
        case .readRepositories(_, let userName, _):
            if let userName = userName {
                return "repositories/\(userName)"
            } else {
                return "repositories"
            }
        case let .readRepository(_, owner, name):
            return "repositories/\(owner)/\(name)"
        }
    }
}
