//
//  ProjectHook.swift
//  
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

    public init(_ json: [String: AnyObject]) {
        if let id = json["id"] as? Int {
            self.id = id
            if let urlString = json["url"] as? String, let parsedURL = URL(string: urlString) {
                url = parsedURL
            }
            projectID = json["project_id"] as? Int
            pushEvents = json["push_events"] as? Bool
            issuesEvents = json["issues_events"] as? Bool
            mergeRequestsEvents = json["merge_requests_events"] as? Bool
            tagPushEvents = json["tag_push_events"] as? Bool
            noteEvents = json["note_events"] as? Bool
            buildEvents = json["build_events"] as? Bool
            pipelineEvents = json["pipeline_events"] as? Bool
            wikiPageEvents = json["wiki_page_events"] as? Bool
            enableSSLVerification = json["enable_ssl_verification"] as? Bool
            createdAt = Time.rfc3339Date(json["created_at"] as? String)
        }
    }
}

public extension GitAccount {

    /**
     Get a list of project hooks.
     - parameter id: The ID of the project or namespace/project name.
                     Make sure that the namespace/project-name is URL-encoded, eg. "%2F" for "/".
     - parameter completion: Callback for the outcome of the fetch.
     */
    public func projectHooks(_ session: GitURLSession = URLSession.shared,
                             id: String,
                             completion: @escaping (
                                _ response: Response<[ProjectHook]>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = ProjectRouter.readProjectHooks(configuration: configuration, id: id)

        return router.loadJSON(session, expectedResultType: [[String: AnyObject]].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            }

            if let json = json {
                let hooks = json.map { ProjectHook($0) }
                completion(Response.success(hooks))
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
    public func projectHook(_ session: GitURLSession = URLSession.shared,
                            id: String,
                            hookId: String,
                            completion: @escaping (
                                _ response: Response<ProjectHook>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = ProjectRouter.readProjectHook(configuration: configuration, id: id, hookId: hookId)

        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            }

            if let json = json {
                let hook = ProjectHook(json)
                completion(Response.success(hook))
            }
        }
    }
}
