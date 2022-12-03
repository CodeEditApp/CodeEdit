//
//  Project.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum VisibilityLevel: Int {
    case `private` = 0
    case `internal` = 10
    case `public` = 20
}

class Project: Codable {
    let id: Int
    let owner: GitLabUser
    var name: String?
    var nameWithNamespace: String?
    var isPrivate: Bool?
    var projectDescription: String?
    var sshURL: URL?
    var cloneURL: URL?
    var webURL: URL?
    var path: String?
    var pathWithNamespace: String?
    var containerRegisteryEnabled: Bool?
    var defaultBranch: String?
    var tagList: [String]?
    var isArchived: Bool?
    var issuesEnabled: Bool?
    var mergeRequestsEnabled: Bool?
    var wikiEnabled: Bool?
    var buildsEnabled: Bool?
    var snippetsEnabled: Bool?
    var sharedRunnersEnabled: Bool?
    var creatorID: Int?
    var namespace: Namespace?
    var avatarURL: URL?
    var starCount: Int?
    var forksCount: Int?
    var openIssuesCount: Int?
    var runnersToken: String?
    var publicBuilds: Bool?
    var createdAt: Date?
    var lastActivityAt: Date?
    var lfsEnabled: Bool?
    var visibilityLevel: String?
    var onlyAllowMergeIfBuildSucceeds: Bool?
    var requestAccessEnabled: Bool?
    var permissions: String?

    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case name
        case nameWithNamespace = "name_with_namespace"
        case isPrivate = "public"
        case projectDescription = "description"
        case sshURL = "ssh_url_to_repo"
        case cloneURL = "http_url_to_repo"
        case webURL = "web_url"
        case path
        case pathWithNamespace = "path_with_namespace"
        case containerRegisteryEnabled = "container_registry_enabled"
        case defaultBranch = "default_branch"
        case tagList = "tag_list"
        case isArchived = "archived"
        case issuesEnabled = "issues_enabled"
        case mergeRequestsEnabled = "merge_requests_enabled"
        case wikiEnabled = "wiki_enabled"
        case buildsEnabled = "builds_enabled"
        case snippetsEnabled = "snippets_enabled"
        case sharedRunnersEnabled = "shared_runners_enabled"
        case publicBuilds = "public_builds"
        case creatorID = "creator_id"
        case namespace
        case avatarURL = "avatar_url"
        case starCount = "star_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case visibilityLevel = "visibility_level"
        case createdAt = "created_at"
        case lastActivityAt = "last_activity_at"
        case lfsEnabled = "lfs_enabled"
        case runnersToken = "runners_token"
        case onlyAllowMergeIfBuildSucceeds = "only_allow_merge_if_build_succeeds"
        case requestAccessEnabled = "request_access_enabled"
        case permissions = "permissions"
    }
}
