//
//  Permissions.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class Permissions: Codable {
    open var projectAccess: ProjectAccess?
    open var groupAccess: GroupAccess?

    public init(_ json: [String: AnyObject]) {
        projectAccess = ProjectAccess(json["project_access"] as? [String: AnyObject] ?? [:])
        groupAccess = GroupAccess(json["group_access"] as? [String: AnyObject] ?? [:])
    }
}
