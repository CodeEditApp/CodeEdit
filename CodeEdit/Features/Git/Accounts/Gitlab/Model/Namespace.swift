//
//  Namespace.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class Namespace: Codable {
    var id: Int?
    var name: String?
    var path: String?
    var ownerID: Int?
    var createdAt: Date?
    var updatedAt: Date?
    var namespaceDescription: String?
    var avatar: AvatarURL?
    var shareWithGroupLocked: Bool?
    var visibilityLevel: Int?
    var requestAccessEnabled: Bool?
    var deletedAt: Date?
    var lfsEnabled: Bool?

    init(_ json: [String: AnyObject]) {
        if let id = json["id"] as? Int {
            self.id = id
            name = json["name"] as? String
            path = json["path"] as? String
            ownerID = json["owner_id"] as? Int
            createdAt = Time.rfc3339Date(json["created_at"] as? String)
            updatedAt = Time.rfc3339Date(json["updated_at"] as? String)
            namespaceDescription = json["description"] as? String
            avatar = AvatarURL(json["avatar"] as? [String: AnyObject] ?? [:])
            shareWithGroupLocked = json["share_with_group_lock"] as? Bool
            visibilityLevel = json["visibility_level"] as? Int
            requestAccessEnabled = json["request_access_enabled"] as? Bool
            deletedAt = Time.rfc3339Date(json["deleted_at"] as? String)
            lfsEnabled = json["lfs_enabled"] as? Bool
        }
    }
}
