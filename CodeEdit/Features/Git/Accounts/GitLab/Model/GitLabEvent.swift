//
//  GitLabEvent.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class GitLabEvent: Codable {
    var title: String?
    var projectID: Int?
    var actionName: String?
    var targetID: Int?
    var targetType: String?
    var authorID: Int?
    var data: GitLabEventData?
    var targetTitle: String?
    var author: GitLabUser?
    var authorUsername: String?
    var createdAt: Date?
    var note: GitLabEventNote?

    enum CodingKeys: String, CodingKey {
        case title
        case projectID = "project_id"
        case actionName = "action_name"
        case targetID = "target_id"
        case targetType = "target_type"
        case authorID = "author_id"
        case data
        case targetTitle = "target_title"
        case author
        case authorUsername = "author_username"
        case createdAt = "created_at"
        case note
    }
}
