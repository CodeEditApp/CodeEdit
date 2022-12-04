//
//  GitHubPullRequestRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanshi Li on 2022/03/31.
//

import Foundation

enum GitHubPullRequestRouter: GitJSONPostRouter {
    case readPullRequest(GitRouterConfiguration, String, String, String)
    case readPullRequests(
        GitRouterConfiguration, String, String, String?, String?, GitHubOpenness, GitSortType, GitSortDirection
    )

    var method: GitHTTPMethod {
        switch self {
        case .readPullRequest,
             .readPullRequests:
            return .GET
        }
    }

    var encoding: GitHTTPEncoding {
        switch self {
        default:
            return .url
        }
    }

    var configuration: GitRouterConfiguration? {
        switch self {
        case let .readPullRequest(config, _, _, _): return config
        case let .readPullRequests(config, _, _, _, _, _, _, _): return config
        }
    }

    var params: [String: Any] {
        switch self {
        case .readPullRequest:
            return [:]
        case let .readPullRequests(_, _, _, base, head, state, sort, direction):
            var parameters = [
                "state": state.rawValue,
                "sort": sort.rawValue,
                "direction": direction.rawValue
            ]

            if let base = base {
                parameters["base"] = base
            }

            if let head = head {
                parameters["head"] = head
            }

            return parameters
        }
    }

    var path: String {
        switch self {
        case let .readPullRequest(_, owner, repository, number):
            return "repos/\(owner)/\(repository)/pulls/\(number)"
        case let .readPullRequests(_, owner, repository, _, _, _, _, _):
            return "repos/\(owner)/\(repository)/pulls"
        }
    }
}
