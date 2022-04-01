//
//  EventData.swift
//  
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
    open var commits: [Commit]?
    open var totalCommitsCount: Int?

    public init(_ json: [String: AnyObject]) {
        objectKind = json["object_kind"] as? String
        eventName = json["event_name"] as? String
        before = json["before"] as? String
        after = json["after"] as? String
        ref = json["ref"] as? String
        checkoutSha = json["checkout_sha"] as? String
        message = json["message"] as? String
        userID = json["user_id"] as? Int
        userName = json["user_name"] as? String
        userEmail = json["user_email"] as? String
        if let urlString = json["user_avater"] as? String, let urlFromString = URL(string: urlString) {
            userAvatar = urlFromString
        }
        projectID = json["project_id"] as? Int
        project = Project(json["project"] as? [String: AnyObject] ?? [:])
        commits =  (json["commits"] as? [[String: AnyObject]])?.map { Commit($0) }
        totalCommitsCount = json["total_commits_count"] as? Int
    }
}
