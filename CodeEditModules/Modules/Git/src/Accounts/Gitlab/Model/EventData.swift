//
//  EventData.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class EventData: Codable {
    open var objectKind: String?
    open var eventName: String?
    open var before: String?
    open var after: String?
    open var ref: String?
    open var checkoutSha: String?
    open var message: String?
    open var userID: Int?
    open var userName: String?
    open var userEmail: String?
    open var userAvatar: URL?
    open var projectID: Int?
    open var project: Project?
    open var commits: [GitlabCommit]?
    open var totalCommitsCount: Int?

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
