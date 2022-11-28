//
//  GitLabUser.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

class GitLabUser: Codable {
    var id: Int
    var username: String?
    var state: String?
    var avatarURL: URL?
    var webURL: URL?
    var createdAt: Date?
    var isAdmin: Bool?
    var name: String?
    var lastSignInAt: Date?
    var confirmedAt: Date?
    var email: String?
    var projectsLimit: Int?
    var currentSignInAt: Date?
    var canCreateGroup: Bool?
    var canCreateProject: Bool?
    var twoFactorEnabled: Bool?
    var external: Bool?

    init(_ json: [String: Any]) {
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

extension GitLabAccount {

    /**
     Fetches the currently logged in user
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<GitLabUser, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = UserRouter.readAuthenticatedUser(self.configuration)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: GitLabUser.self) { data, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let data = data {
                completion(Result.success(data))
            }
        }
    }
}
