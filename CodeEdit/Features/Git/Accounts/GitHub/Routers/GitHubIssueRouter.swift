//
//  GitHubIssueRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum GitHubIssueRouter: GitJSONPostRouter {
    case readAuthenticatedIssues(GitRouterConfiguration, String, String, GitHubOpenness)
    case readIssue(GitRouterConfiguration, String, String, Int)
    case readIssues(GitRouterConfiguration, String, String, String, String, GitHubOpenness)
    case postIssue(GitRouterConfiguration, String, String, String, String?, String?, [String])
    case patchIssue(GitRouterConfiguration, String, String, Int, String?, String?, String?, GitHubOpenness?)
    case commentIssue(GitRouterConfiguration, String, String, Int, String)
    case readIssueComments(GitRouterConfiguration, String, String, Int, String, String)
    case patchIssueComment(GitRouterConfiguration, String, String, Int, String)

    var method: GitHTTPMethod {
        switch self {
        case .postIssue, .patchIssue, .commentIssue, .patchIssueComment:
            return .POST
        default:
            return .GET
        }
    }

    var encoding: GitHTTPEncoding {
        switch self {
        case .postIssue, .patchIssue, .commentIssue, .patchIssueComment:
            return .json
        default:
            return .url
        }
    }

    var configuration: GitRouterConfiguration? {
        switch self {
        case let .readAuthenticatedIssues(config, _, _, _): return config
        case let .readIssue(config, _, _, _): return config
        case let .readIssues(config, _, _, _, _, _): return config
        case let .postIssue(config, _, _, _, _, _, _): return config
        case let .patchIssue(config, _, _, _, _, _, _, _): return config
        case let .commentIssue(config, _, _, _, _): return config
        case let .readIssueComments(config, _, _, _, _, _): return config
        case let .patchIssueComment(config, _, _, _, _): return config
        }
    }

    var params: [String: Any] {
        switch self {
        case let .readAuthenticatedIssues(_, page, perPage, state):
            return ["per_page": perPage, "page": page, "state": state.rawValue]
        case .readIssue:
            return [:]
        case let .readIssues(_, _, _, page, perPage, state):
            return ["per_page": perPage, "page": page, "state": state.rawValue]
        case let .postIssue(_, _, _, title, body, assignee, labels):
            var params: [String: Any] = ["title": title]
            if let body = body {
                params["body"] = body
            }
            if let assignee = assignee {
                params["assignee"] = assignee
            }
            if !labels.isEmpty {
                params["labels"] = labels
            }
            return params
        case let .patchIssue(_, _, _, _, title, body, assignee, state):
            var params: [String: String] = [:]
            if let title = title {
                params["title"] = title
            }
            if let body = body {
                params["body"] = body
            }
            if let assignee = assignee {
                params["assignee"] = assignee
            }
            if let state = state {
                params["state"] = state.rawValue
            }
            return params
        case let .commentIssue(_, _, _, _, body):
            return ["body": body]
        case let .readIssueComments(_, _, _, _, page, perPage):
            return ["per_page": perPage, "page": page]
        case let .patchIssueComment(_, _, _, _, body):
            return ["body": body]
        }
    }

    var path: String {
        switch self {
        case .readAuthenticatedIssues:
            return "issues"
        case let .readIssue(_, owner, repository, number):
            return "repos/\(owner)/\(repository)/issues/\(number)"
        case let .readIssues(_, owner, repository, _, _, _):
            return "repos/\(owner)/\(repository)/issues"
        case let .postIssue(_, owner, repository, _, _, _, _):
            return "repos/\(owner)/\(repository)/issues"
        case let .patchIssue(_, owner, repository, number, _, _, _, _):
            return "repos/\(owner)/\(repository)/issues/\(number)"
        case let .commentIssue(_, owner, repository, number, _):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        case let .readIssueComments(_, owner, repository, number, _, _):
            return "repos/\(owner)/\(repository)/issues/\(number)/comments"
        case let .patchIssueComment(_, owner, repository, number, _):
            return "repos/\(owner)/\(repository)/issues/comments/\(number)"
        }
    }
}
