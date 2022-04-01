//
//  Project.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public enum VisibilityLevel: Int {
    case `private` = 0
    case `internal` = 10
    case `public` = 20
}

// swiftlint:disable all
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

// swiftlint:disable all
public extension GitlabAccount {
    /**
     Fetches the Projects for which the authenticated user is a member.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project. Default is false,
     set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func projects(_ session: GitURLSession = URLSession.shared,
                  page: String = "1",
                  perPage: String = "20",
                  archived: Bool = false,
                  visibility: Visibility = Visibility.all,
                  orderBy: OrderBy = OrderBy.creationDate,
                  sort: Sort = Sort.descending,
                  search: String = "",
                  simple: Bool = false,
                  completion: @escaping (
                    _ response: Result<[Project], Error>) -> Void) -> URLSessionDataTaskProtocol? {

                        let router = ProjectRouter.readAuthenticatedProjects(configuration: configuration,
                                                                             page: page,
                                                                             perPage: perPage,
                                                                             archived: archived,
                                                                             visibility: visibility,
                                                                             orderBy: orderBy,
                                                                             sort: sort,
                                                                             search: search,
                                                                             simple: simple)
                        return router.load(session,
                                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                           expectedResultType: Project.self) { json, error in

                            if let error = error {
                                completion(Result.failure(error))
                            }

                            if let json = json {
                                completion(Result.success([json]))
                            }
                        }
                    }

    /**
     Fetches project for a specified ID.
     - parameter id: The ID or namespace/project-name of the project.
     Make sure that the namespace/project-name is URL-encoded, eg. "%2F" for "/".
     - parameter completion: Callback for the outcome of the fetch.
     */
    func project(_ session: GitURLSession = URLSession.shared,
                 id: String,
                 completion: @escaping (_ response: Result<Project, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = ProjectRouter.readSingleProject(configuration: configuration, id: id)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: Project.self) { json, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let json = json {
                completion(Result.success(json))
            }
        }
    }

    /**
     Fetches the Projects which the authenticated user can see.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project. Default is false,
     set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func visibleProjects(_ session: GitURLSession = URLSession.shared,
                         page: String = "1",
                         perPage: String = "20",
                         archived: Bool = false,
                         visibility: Visibility = Visibility.all,
                         orderBy: OrderBy = OrderBy.creationDate,
                         sort: Sort = Sort.descending,
                         search: String = "",
                         simple: Bool = false,
                         completion: @escaping (
                            _ response: Result<Project, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                                let router = ProjectRouter.readVisibleProjects(configuration: configuration,
                                                                               page: page,
                                                                               perPage: perPage,
                                                                               archived: archived,
                                                                               visibility: visibility,
                                                                               orderBy: orderBy,
                                                                               sort: sort,
                                                                               search: search,
                                                                               simple: simple)

                                return router.load(session,
                                                   dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                                   expectedResultType: Project.self) { json, error in

                                    if let error = error {
                                        completion(Result.failure(error))
                                    }

                                    if let json = json {
                                        completion(Result.success(json))
                                    }
                                }
                            }

    /**
     Fetches the Projects which are owned by the authenticated user.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project. Default is false,
     set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func ownedProjects(_ session: GitURLSession = URLSession.shared,
                       page: String = "1",
                       perPage: String = "20",
                       archived: Bool = false,
                       visibility: Visibility = Visibility.all,
                       orderBy: OrderBy = OrderBy.creationDate,
                       sort: Sort = Sort.descending,
                       search: String = "",
                       simple: Bool = false,
                       completion: @escaping (
                        _ response: Result<Project, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = ProjectRouter.readOwnedProjects(configuration: configuration,
                                                                         page: page,
                                                                         perPage: perPage,
                                                                         archived: archived,
                                                                         visibility: visibility,
                                                                         orderBy: orderBy,
                                                                         sort: sort,
                                                                         search: search,
                                                                         simple: simple)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: Project.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }

    /**
     Fetches the Projects which are starred by the authenticated user.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project.
     Default is false, set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func starredProjects(_ session: GitURLSession = URLSession.shared,
                         page: String = "1",
                         perPage: String = "20",
                         archived: Bool = false,
                         visibility: Visibility = Visibility.all,
                         orderBy: OrderBy = OrderBy.creationDate,
                         sort: Sort = Sort.descending,
                         search: String = "",
                         simple: Bool = false,
                         completion: @escaping (
                            _ response: Result<Project, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                                let router = ProjectRouter.readStarredProjects(configuration: configuration,
                                                                               page: page,
                                                                               perPage: perPage,
                                                                               archived: archived,
                                                                               visibility: visibility,
                                                                               orderBy: orderBy,
                                                                               sort: sort,
                                                                               search: search,
                                                                               simple: simple)

                                return router.load(session,
                                                   dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                                   expectedResultType: Project.self) { json, error in

                                    if let error = error {
                                        completion(Result.failure(error))
                                    }

                                    if let json = json {
                                        completion(Result.success(json))
                                    }
                                }
                            }

    /**
     Fetches all GitLab projects in the server **(admin only)**.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project.
     Default is false, set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func allProjects(_ session: GitURLSession = URLSession.shared,
                     page: String = "1",
                     perPage: String = "20",
                     archived: Bool = false,
                     visibility: Visibility = Visibility.all,
                     orderBy: OrderBy = OrderBy.creationDate,
                     sort: Sort = Sort.descending,
                     search: String = "",
                     simple: Bool = false,
                     completion: @escaping (
                        _ response: Result<Project, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = ProjectRouter.readAllProjects(configuration: configuration,
                                                                       page: page,
                                                                       perPage: perPage,
                                                                       archived: archived,
                                                                       visibility: visibility,
                                                                       orderBy: orderBy,
                                                                       sort: sort,
                                                                       search: search,
                                                                       simple: simple)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: Project.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }

    /**
     Fetches the events for the specified project. Sorted from newest to oldest.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter id: The ID or NAMESPACE/PROJECT_NAME of the project.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func projectEvents(_ session: GitURLSession = URLSession.shared,
                       id: String,
                       page: String = "1",
                       perPage: String = "20",
                       completion: @escaping (
                        _ response: Result<Event, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = ProjectRouter.readProjectEvents(configuration: configuration,
                                                                         id: id,
                                                                         page: page,
                                                                         perPage: perPage)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: Event.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }
}
