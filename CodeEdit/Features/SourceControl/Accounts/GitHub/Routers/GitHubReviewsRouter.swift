//
//  GitHubReviewsRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanshi Li on 2022/03/31.
//

import Foundation

enum GitHubReviewsRouter: GitJSONPostRouter {
    case listReviews(GitRouterConfiguration, String, String, Int)

    var method: GitHTTPMethod {
        switch self {
        case .listReviews:
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
        case let .listReviews(config, _, _, _):
            return config
        }
    }

    var params: [String: Any] {
        switch self {
        case .listReviews:
            return [:]
        }
    }

    var path: String {
        switch self {
        case let .listReviews(_, owner, repository, pullRequestNumber):
            return "repos/\(owner)/\(repository)/pulls/\(pullRequestNumber)/reviews"
        }
    }
}
