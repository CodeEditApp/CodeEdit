//
//  GitHubRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanshi Li on 2022/03/31.
//

import Foundation

enum GitHubRouter: GitJSONPostRouter {
    case deleteReference(GitRouterConfiguration, String, String, String)

    var configuration: GitRouterConfiguration? {
        switch self {
        case let .deleteReference(config, _, _, _): return config
        }
    }

    var method: GitHTTPMethod {
        switch self {
        case .deleteReference:
            return .DELETE
        }
    }

    var encoding: GitHTTPEncoding {
        switch self {
        case .deleteReference:
            return .url
        }
    }

    var params: [String: Any] {
        switch self {
        case .deleteReference:
            return [:]
        }
    }

    var path: String {
        switch self {
        case let .deleteReference(_, owner, repo, reference):
            return "repos/\(owner)/\(repo)/git/refs/\(reference)"
        }
    }
}
