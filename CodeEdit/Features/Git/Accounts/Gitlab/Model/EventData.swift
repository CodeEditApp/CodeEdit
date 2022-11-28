//
//  EventData.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class EventData: Codable {
    var objectKind: String?
    var eventName: String?
    var before: String?
    var after: String?
    var ref: String?
    var checkoutSha: String?
    var message: String?
    var userID: Int?
    var userName: String?
    var userEmail: String?
    var userAvatar: URL?
    var projectID: Int?
    var project: Project?
    var commits: [GitLabCommit]?
    var totalCommitsCount: Int?

    enum CodingKeys: String, CodingKey {
        case objectKind = "object_kind"
        case eventName = "event_name"
        case before
        case after
        case ref
        case checkoutSha = "checkout_sha"
        case message
        case userID = "user_id"
        case userName = "user_name"
        case userEmail = "user_email"
        case userAvatar = "user_avater"
        case projectID = "project_id"
        case project
        case commits
        case totalCommitsCount = "total_commits_count"
    }
}
