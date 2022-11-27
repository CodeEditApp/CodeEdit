//
//  BitbucketRepositoryRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum BitbucketRepositoryRouter: Router {
    case readRepositories(RouterConfiguration, String?, [String: String])
    case readRepository(RouterConfiguration, String, String)

    var configuration: RouterConfiguration? {
        switch self {
        case .readRepositories(let config, _, _): return config
        case .readRepository(let config, _, _): return config
        }
    }

    var method: HTTPMethod {
        .GET
    }

    var encoding: HTTPEncoding {
        .url
    }

    var params: [String: Any] {
        switch self {
        case .readRepositories(_, let userName, var nextParameters):
            if userName != nil {
                return nextParameters as [String: Any]
            } else {
                nextParameters += ["role": "member"]
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
