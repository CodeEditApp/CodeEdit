//
//  Event.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class Event: Codable {
    open var title: String?
    open var projectID: Int?
    open var actionName: String?
    open var targetID: Int?
    open var targetType: String?
    open var authorID: Int?
    open var data: EventData?
    open var targetTitle: String?
    open var author: GitlabUser?
    open var authorUsername: String?
    open var createdAt: Date?
    open var note: EventNote?

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
