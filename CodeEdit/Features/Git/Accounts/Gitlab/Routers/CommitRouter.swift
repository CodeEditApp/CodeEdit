//
//  CommitRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum CommitRouter: Router {
    case readCommits(RouterConfiguration, id: String, refName: String, since: String, until: String)
    case readCommit(RouterConfiguration, id: String, sha: String)
    case readCommitDiffs(RouterConfiguration, id: String, sha: String)
    case readCommitComments(RouterConfiguration, id: String, sha: String)
    case readCommitStatuses(
        RouterConfiguration,
        id: String,
        sha: String,
        ref: String,
        stage: String,
        name: String,
        all: Bool
    )

    var configuration: RouterConfiguration? {
        switch self {
        case let .readCommits(config, _, _, _, _): return config
        case let .readCommit(config, _, _): return config
        case let .readCommitDiffs(config, _, _): return config
        case let .readCommitComments(config, _, _): return config
        case let .readCommitStatuses(config, _, _, _, _, _, _): return config
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
        case let .readCommits(_, _, refName, since, until):
            return ["ref_name": refName, "since": since, "until": until]
        case .readCommit:
            return [:]
        case .readCommitDiffs:
            return [:]
        case .readCommitComments:
            return [:]
        case let .readCommitStatuses(_, _, _, ref, stage, name, all):
            return ["ref": ref, "stage": stage, "name": name, "all": String(all)]
        }
    }

    var path: String {
        switch self {
        case let .readCommits(_, id, _, _, _):
            return "project/\(id)/repository/commits"
        case let .readCommit(_, id, sha):
            return "project/\(id)/repository/commits/\(sha)"
        case let .readCommitDiffs(_, id, sha):
            return "project/\(id)/repository/commits/\(sha)/diff"
        case let .readCommitComments(_, id, sha):
            return "project/\(id)/repository/commits/\(sha)/comments"
        case let .readCommitStatuses(_, id, sha, _, _, _, _):
            return "project/\(id)/repository/commits/\(sha)/statuses"
        }
    }
}
