//
//  ProjectHook.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class ProjectHook: Codable {
    open var id: Int?
    open var url: URL?
    open var projectID: Int?
    open var pushEvents: Bool?
    open var issuesEvents: Bool?
    open var mergeRequestsEvents: Bool?
    open var tagPushEvents: Bool?
    open var noteEvents: Bool?
    open var buildEvents: Bool?
    open var pipelineEvents: Bool?
    open var wikiPageEvents: Bool?
    open var enableSSLVerification: Bool?
    open var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case projectID = "project_id"
        case pushEvents = "push_events"
        case issuesEvents = "issues_events"
        case mergeRequestsEvents = "merge_requests_events"
        case tagPushEvents = "tag_push_events"
        case noteEvents = "note_events"
        case buildEvents = "build_events"
        case pipelineEvents = "pipeline_events"
        case wikiPageEvents = "wiki_page_events"
        case enableSSLVerification = "enable_ssl_verification"
        case createdAt = "created_at"
    }
}

public extension GitlabAccount {

    /**
     Get a list of project hooks.
     - parameter id: The ID of the project or namespace/project name.
     Make sure that the namespace/project-name is URL-encoded, eg. "%2F" for "/".
     - parameter completion: Callback for the outcome of the fetch.
     */
    func projectHooks(_ session: GitURLSession = URLSession.shared,
                      id: String,
                      completion: @escaping (
                        _ response: Result<ProjectHook, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = ProjectRouter.readProjectHooks(configuration: configuration, id: id)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: ProjectHook.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }

    /**
     Get a specific hook from a project.
     - parameter id: The ID of the project or namespace/project name.
     Make sure that the namespace/project-name is URL-encoded, eg. "%2F" for "/".
     - parameter hookId: The ID of the hook in the project
     (you can get the ID of a hook by searching for it with the **allProjectHooks** request).
     - parameter completion: Callback for the outcome of the fetch.
     */
    func projectHook(_ session: GitURLSession = URLSession.shared,
                     id: String,
                     hookId: String,
                     completion: @escaping (
                        _ response: Result<ProjectHook, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = ProjectRouter.readProjectHook(configuration: configuration,
                                                                       id: id,
                                                                       hookId: hookId)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: ProjectHook.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }
}
