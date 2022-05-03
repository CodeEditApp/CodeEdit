//
//  GithubUser.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class GithubUser: Codable {
    open internal(set) var id: Int = -1
    open var login: String?
    open var avatarURL: String?
    open var gravatarID: String?
    open var type: String?
    open var name: String?
    open var company: String?
    open var email: String?
    open var numberOfPublicRepos: Int?
    open var numberOfPublicGists: Int?
    open var numberOfPrivateRepos: Int?
    open var nodeID: String?
    open var url: String?
    open var htmlURL: String?
    open var gistsURL: String?
    open var starredURL: String?
    open var subscriptionsURL: String?
    open var reposURL: String?
    open var eventsURL: String?
    open var receivedEventsURL: String?
    open var createdAt: Date?
    open var updatedAt: Date?
    open var numberOfPrivateGists: Int?
    open var numberOfOwnPrivateRepos: Int?
    open var twoFactorAuthenticationEnabled: Bool?

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

public extension GithubAccount {
    /**
         Fetches a user or organization
         - parameter session: GitURLSession, defaults to URLSession.shared
         - parameter name: The name of the user or organization.
         - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func user(
        _ session: GitURLSession = URLSession.shared,
        name: String,
        completion: @escaping (_ response: Result<GithubUser, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GithubUserRouter.readUser(name, configuration)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: GithubUser.self) { user, error in
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
    func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<GithubUser, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GithubUserRouter.readAuthenticatedUser(configuration)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: GithubUser.self) { user, error in
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
