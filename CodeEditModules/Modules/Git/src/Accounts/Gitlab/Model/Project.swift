//
//  Project.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public enum VisibilityLevel: Int {
    case `private` = 0
    case `internal` = 10
    case `public` = 20
}

open class Project: Codable {
    public let id: Int
    public let owner: GitlabUser
    open var name: String?
    open var nameWithNamespace: String?
    open var isPrivate: Bool?
    open var projectDescription: String?
    open var sshURL: URL?
    open var cloneURL: URL?
    open var webURL: URL?
    open var path: String?
    open var pathWithNamespace: String?
    open var containerRegisteryEnabled: Bool?
    open var defaultBranch: String?
    open var tagList: [String]?
    open var isArchived: Bool?
    open var issuesEnabled: Bool?
    open var mergeRequestsEnabled: Bool?
    open var wikiEnabled: Bool?
    open var buildsEnabled: Bool?
    open var snippetsEnabled: Bool?
    open var sharedRunnersEnabled: Bool?
    open var creatorID: Int?
    open var namespace: Namespace?
    open var avatarURL: URL?
    open var starCount: Int?
    open var forksCount: Int?
    open var openIssuesCount: Int?
    open var runnersToken: String?
    open var publicBuilds: Bool?
    open var createdAt: Date?
    open var lastActivityAt: Date?
    open var lfsEnabled: Bool?
    open var visibilityLevel: String?
    open var onlyAllowMergeIfBuildSucceeds: Bool?
    open var requestAccessEnabled: Bool?
    open var permissions: String?

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
