//
//  Repositories.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class GithubRepositories: Codable {
    open private(set) var id: Int = -1
    open private(set) var owner = GithubUser()
    open var name: String?
    open var fullName: String?
    open private(set) var isPrivate: Bool = false
    open var repositoryDescription: String?
    open private(set) var isFork: Bool = false
    open var gitURL: String?
    open var sshURL: String?
    open var cloneURL: String?
    open var htmlURL: String?
    open private(set) var size: Int? = -1
    open var lastPush: Date?
    open var stargazersCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case owner
        case name
        case fullName = "full_name"
        case isPrivate = "private"
        case repositoryDescription = "description"
        case isFork = "fork"
        case gitURL = "git_url"
        case sshURL = "ssh_url"
        case cloneURL = "clone_url"
        case htmlURL = "html_url"
        case size
        case lastPush = "pushed_at"
        case stargazersCount = "stargazers_count"
    }
}

// swiftlint:disable line_length
public extension GithubAccount {

    /**
        Fetches the Repositories for a user or organization
            - parameter session: GitURLSession, defaults to URLSession.shared
            - parameter owner: The user or organization that owns the repositories. If `nil`,
                               fetches repositories for the authenticated user.
            - parameter page: Current page for repository pagination. `1` by default.
            - parameter perPage: Number of repositories per page. `100` by default.
            - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func repositories(_ session: GitURLSession = URLSession.shared,
                      owner: String? = nil,
                      page: String = "1",
                      perPage: String = "100",
                      completion: @escaping (
                        _ response: Result<[GithubRepositories], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = (owner != nil)
            ? GithubRepositoryRouter.readRepositories(configuration, owner!, page, perPage)
            : GithubRepositoryRouter.readAuthenticatedRepositories(configuration, page, perPage)

        return router.load(session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter), expectedResultType: [GithubRepositories].self) { repos, error in
            if let error = error {
                completion(.failure(error))
            }

            if let repos = repos {
                completion(.success(repos))
            }
        }
    }

    /**
         Fetches a repository for a user or organization
         - parameter session: GitURLSession, defaults to URLSession.shared
         - parameter owner: The user or organization that owns the repositories.
         - parameter name: The name of the repository to fetch.
         - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func repository(_ session: GitURLSession = URLSession.shared,
                    owner: String,
                    name: String,
                    completion: @escaping (
                        _ response: Result<GithubRepositories, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GithubRepositoryRouter.readRepository(configuration, owner, name)

        return router.load(session, dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter), expectedResultType: GithubRepositories.self) { repo, error in
            if let error = error {
                completion(.failure(error))
            } else {
                if let repo = repo {
                    completion(.success(repo))
                }
            }
        }
    }
}
