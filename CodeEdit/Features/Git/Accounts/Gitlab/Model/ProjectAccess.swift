//
//  ProjectAccess.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class ProjectAccess: Codable {
    var accessLevel: Int?
    var notificationLevel: Int?

    init(_ json: [String: AnyObject]) {
        accessLevel = json["access_level"] as? Int
        notificationLevel = json["notification_level"] as? Int
    }
}
