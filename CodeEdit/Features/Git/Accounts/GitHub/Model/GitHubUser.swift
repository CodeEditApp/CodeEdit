//
//  GitHubUser.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class GitHubUser: Codable {
    private(set) var id: Int = -1
    var login: String?
    var avatarURL: String?
    var gravatarID: String?
    var type: String?
    var name: String?
    var company: String?
    var email: String?
    var numberOfPublicRepos: Int?
    var numberOfPublicGists: Int?
    var numberOfPrivateRepos: Int?
    var nodeID: String?
    var url: String?
    var htmlURL: String?
    var gistsURL: String?
    var starredURL: String?
    var subscriptionsURL: String?
    var reposURL: String?
    var eventsURL: String?
    var receivedEventsURL: String?
    var createdAt: Date?
    var updatedAt: Date?
    var numberOfPrivateGists: Int?
    var numberOfOwnPrivateRepos: Int?
    var twoFactorAuthenticationEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case type
        case name
        case company
        case email
        case numberOfPublicRepos = "public_repos"
        case numberOfPublicGists = "public_gists"
        case numberOfPrivateRepos = "total_private_repos"
        case nodeID = "node_id"
        case url
        case htmlURL = "html_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case numberOfPrivateGists = "private_gists"
        case numberOfOwnPrivateRepos = "owned_private_repos"
        case twoFactorAuthenticationEnabled = "two_factor_authentication"
    }
}

extension GitHubAccount {
    /**
         Fetches a user or organization
         - parameter session: GitURLSession, defaults to URLSession.shared
         - parameter name: The name of the user or organization.
         - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func user(_ session: GitURLSession = URLSession.shared,
              name: String,
              completion: @escaping (_ response: Result<GitHubUser, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = GitHubUserRouter.readUser(name, configuration)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: GitHubUser.self) { user, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let user = user {
                    completion(.success(user))
                }
            }
        }
    }

    /**
         Fetches the authenticated user
         - parameter session: GitURLSession, defaults to URLSession.shared
         - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func me(_ session: GitURLSession = URLSession.shared,
            completion: @escaping (_ response: Result<GitHubUser, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = GitHubUserRouter.readAuthenticatedUser(configuration)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: GitHubUser.self) { user, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let user = user {
                    completion(.success(user))
                }
            }
        }
    }
}
