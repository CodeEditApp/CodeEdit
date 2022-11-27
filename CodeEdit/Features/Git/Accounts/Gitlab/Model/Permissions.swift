//
//  Permissions.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class Permissions: Codable {
    var projectAccess: ProjectAccess?
    var groupAccess: GroupAccess?

    init(_ json: [String: AnyObject]) {
        projectAccess = ProjectAccess(json["project_access"] as? [String: AnyObject] ?? [:])
        groupAccess = GroupAccess(json["group_access"] as? [String: AnyObject] ?? [:])
    }
}
