//
//  Permissions.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class GitLabPermissions: Codable {
    var projectAccess: GitLabProjectAccess?
    var groupAccess: GitLabGroupAccess?

    init(_ json: [String: AnyObject]) {
        projectAccess = GitLabProjectAccess(json["project_access"] as? [String: AnyObject] ?? [:])
        groupAccess = GitLabGroupAccess(json["group_access"] as? [String: AnyObject] ?? [:])
    }
}
