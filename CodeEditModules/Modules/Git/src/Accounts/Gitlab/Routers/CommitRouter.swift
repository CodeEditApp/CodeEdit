//
//  CommitRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum CommitRouter: Router {
    case readCommits(Configuration, id: String, refName: String, since: String, until: String)
    case readCommit(Configuration, id: String, sha: String)
    case readCommitDiffs(Configuration, id: String, sha: String)
    case readCommitComments(Configuration, id: String, sha: String)
    case readCommitStatuses(Configuration, id: String, sha: String, ref: String, stage: String, name: String, all: Bool)

    var configuration: Configuration? {
        switch self {
        case .readCommits(let config, nil, nil, nil, nil): return config
        case .readCommit(let config, nil, nil): return config
        case .readCommitDiffs(let config, nil, nil): return config
        case .readCommitComments(let config, nil, nil): return config
        case .readCommitStatuses(let config, nil, nil, nil, nil, nil, nil): return config
        default: return nil
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
        case .readCommits(nil, nil, let refName, let since, let until):
            return ["ref_name": refName, "since": since, "until": until]
        case .readCommit(nil, nil, nil):
            return [:]
        case .readCommitDiffs(nil, nil, nil):
            return [:]
        case .readCommitComments(nil, nil, nil):
            return [:]
        case .readCommitStatuses(nil, nil, nil, let ref, let stage, let name, let all):
            return ["ref": ref, "stage": stage, "name": name, "all": String(all)]
        default: return [:]
        }
    }

    var path: String {
        switch self {
        case .readCommits(nil, let id, nil, nil, nil):
            return "project/\(id)/repository/commits"
        case .readCommit(nil, let id, let sha):
            return "project/\(id)/repository/commits/\(sha)"
        case .readCommitDiffs(nil, let id, let sha):
            return "project/\(id)/repository/commits/\(sha)/diff"
        case .readCommitComments(nil, let id, let sha):
            return "project/\(id)/repository/commits/\(sha)/comments"
        case .readCommitStatuses(nil, let id, let sha, nil, nil, nil, nil):
            return "project/\(id)/repository/commits/\(sha)/statuses"
        default: return ""
        }
    }
}
