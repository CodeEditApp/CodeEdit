//
//  EventNote.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class EventNote: Codable {
    open var id: Int?
    open var body: String?
    open var attachment: String?
    open var author: GitlabUser?
    open var createdAt: Date?
    open var system: Bool?
    open var upvote: Bool?
    open var downvote: Bool?
    open var noteableID: Int?
    open var noteableType: String?

    public init(_ json: [String: AnyObject]) {
        id = json["id"] as? Int
        body = json["body"] as? String
        attachment = json["attachment"] as? String
        author = GitlabUser(json["author"] as? [String: AnyObject] ?? [:])
        createdAt = Time.rfc3339Date(json["created_at"] as? String)
        system = json["system"] as? Bool
        upvote = json["upvote"] as? Bool
        downvote = json["downvote"] as? Bool
        noteableID = json["noteable_id"] as? Int
        noteableType = json["noteable_type"] as? String
    }
}
