//
//  User.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class User: Codable {
    open let id: Int
    open var username: String?
    open var state: String?
    open var avatarURL: URL?
    open var webURL: URL?
    open var createdAt: Date?
    open var isAdmin: Bool?
    open var name: String?
    open var lastSignInAt: Date?
    open var confirmedAt: Date?
    open var email: String?
    open var projectsLimit: Int?
    open var currentSignInAt: Date?
    open var canCreateGroup: Bool?
    open var canCreateProject: Bool?
    open var twoFactorEnabled: Bool?
    open var external: Bool?

    public init(_ json: [String: Any]) {
        if let id = json["id"] as? Int {
            name = json["name"] as? String
            username = json["username"] as? String
            self.id = id
            state = json["state"] as? String
            if let urlString = json["avatar_url"] as? String, let url = URL(string: urlString) {
                avatarURL = url
            }
            if let urlString = json["web_url"] as? String, let url = URL(string: urlString) {
                webURL = url
            }
            createdAt = Time.rfc3339Date(json["created_at"] as? String)
            isAdmin = json["is_admin"] as? Bool
            lastSignInAt = Time.rfc3339Date(json["last_sign_in_at"] as? String)
            confirmedAt = Time.rfc3339Date(json["confirmed_at"] as? String)
            email = json["email"] as? String
            projectsLimit = json["projects_limit"] as? Int
            currentSignInAt = Time.rfc3339Date(json["current_sign_in_at"] as? String)
            canCreateGroup = json["can_create_group"] as? Bool
            canCreateProject = json["can_create_project"] as? Bool
            twoFactorEnabled = json["two_factor_enabled"] as? Bool
            external = json["external"] as? Bool
        } else {
            id = -1
        }
    }
}

public extension GitAccount {

    /**
     Fetches the currently logged in user
     - parameter completion: Callback for the outcome of the fetch.
     */
    public func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Response<User>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = UserRouter.readAuthenticatedUser(self.configuration)

        return router.loadJSON(session, expectedResultType: [String: Any].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json {
                    let parsedUser = User(json)
                    completion(Response.success(parsedUser))
                }
            }
        }
    }
}
