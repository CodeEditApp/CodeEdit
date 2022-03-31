//
//  Event.swift
//  
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
    open var author: User?
    open var authorUsername: String?
    open var createdAt: Date?
    open var note: EventNote?

    public init(_ json: [String: AnyObject]) {
        title = json["title"] as? String
        projectID = json["project_id"] as? Int
        actionName = json["action_name"] as? String
        targetID = json["target_id"] as? Int
        targetType = json["target_title"] as? String
        authorID = json["author_id"] as? Int
        data = EventData(json["data"] as? [String: AnyObject] ?? [:])
        targetTitle = json["target_title"] as? String
        author = User(json["author"] as? [String: AnyObject] ?? [:])
        authorUsername = json["author_username"] as? String
        createdAt = Time.rfc3339Date(json["created_at"] as? String)
        note = EventNote(json["note"] as? [String: AnyObject] ?? [:])
    }
}
