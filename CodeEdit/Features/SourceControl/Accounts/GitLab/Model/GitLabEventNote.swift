//
//  GitLabEventNote.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class GitLabEventNote: Codable {
    var id: Int?
    var body: String?
    var attachment: String?
    var author: GitLabUser?
    var createdAt: Date?
    var system: Bool?
    var upvote: Bool?
    var downvote: Bool?
    var notableID: Int?
    var notableType: String?

    init(_ json: [String: AnyObject]) {
        id = json["id"] as? Int
        body = json["body"] as? String
        attachment = json["attachment"] as? String
        author = GitLabUser(json["author"] as? [String: AnyObject] ?? [:])
        createdAt = GitTime.rfc3339Date(json["created_at"] as? String)
        system = json["system"] as? Bool
        upvote = json["upvote"] as? Bool
        downvote = json["downvote"] as? Bool
        notableID = json["notable_id"] as? Int
        notableType = json["notable_type"] as? String
    }
}
