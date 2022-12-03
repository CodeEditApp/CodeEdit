//
//  EventNote.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class EventNote: Codable {
    var id: Int?
    var body: String?
    var attachment: String?
    var author: GitLabUser?
    var createdAt: Date?
    var system: Bool?
    var upvote: Bool?
    var downvote: Bool?
    var noteableID: Int?
    var noteableType: String?

    init(_ json: [String: AnyObject]) {
        id = json["id"] as? Int
        body = json["body"] as? String
        attachment = json["attachment"] as? String
        author = GitLabUser(json["author"] as? [String: AnyObject] ?? [:])
        createdAt = Time.rfc3339Date(json["created_at"] as? String)
        system = json["system"] as? Bool
        upvote = json["upvote"] as? Bool
        downvote = json["downvote"] as? Bool
        noteableID = json["noteable_id"] as? Int
        noteableType = json["noteable_type"] as? String
    }
}
