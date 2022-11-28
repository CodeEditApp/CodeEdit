//
//  Gist.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class Gist: Codable {
    private(set) var id: String?
    var url: URL?
    var forksURL: URL?
    var commitsURL: URL?
    var gitPushURL: URL?
    var gitPullURL: URL?
    var commentsURL: URL?
    var htmlURL: URL?
    var files: Files
    var publicGist: Bool?
    var createdAt: Date?
    var updatedAt: Date?
    var description: String?
    var comments: Int?
    var user: GitHubUser?
    var owner: GitHubUser?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case forksURL = "forks_url"
        case commitsURL = "commits_url"
        case gitPushURL = "git_pull_url"
        case gitPullURL = "git_push_url"
        case commentsURL = "comments_url"
        case htmlURL = "html_url"
        case files
        case publicGist = "public"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case description
        case comments
        case user
        case owner
    }
}

extension GitHubAccount {

    /**
     Fetches the gists of the authenticated user
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter page: Current page for gist pagination. `1` by default.
     - parameter perPage: Number of gists per page. `100` by default.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func myGists(
        _ session: GitURLSession = URLSession.shared,
        page: String = "1",
        perPage: String = "100",
        completion: @escaping (
            _ response: Result<[Gist], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.readAuthenticatedGists(configuration, page, perPage)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Gist].self) { gists, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gists = gists {
                    completion(.success(gists))
                }
            }
        }
    }

    /**
     Fetches the gists of the specified user
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The username who owns the gists.
     - parameter page: Current page for gist pagination. `1` by default.
     - parameter perPage: Number of gists per page. `100` by default.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func gists(
        _ session: GitURLSession = URLSession.shared,
        owner: String,
        page: String = "1",
        perPage: String = "100",
        completion: @escaping (
            _ response: Result<[Gist], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.readGists(configuration, owner, page, perPage)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Gist].self) { gists, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gists = gists {
                    completion(.success(gists))
                }
            }
        }
    }

    /**
     Fetches an gist
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter id: The id of the gist.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func gist(
        _ session: GitURLSession = URLSession.shared,
        id: String,
        completion: @escaping (
            _ response: Result<Gist, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.readGist(configuration, id)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: Gist.self) { gist, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gist = gist {
                    completion(.success(gist))
                }
            }
        }
    }

    /**
     Creates an gist with a single file.
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter description: The description of the gist.
     - parameter filename: The name of the file in the gist.
     - parameter fileContent: The content of the file in the gist.
     - parameter publicAccess: The public/private visability of the gist.
     - parameter completion: Callback for the gist that is created.
     */
    @discardableResult
    func postGistFile(_ session: GitURLSession = URLSession.shared,
                      description: String,
                      filename: String,
                      fileContent: String,
                      publicAccess: Bool,
                      completion: @escaping (
                        _ response: Result<Gist, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.postGistFile(configuration, description, filename, fileContent, publicAccess)
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session,
            decoder: decoder,
            expectedResultType: Gist.self) { gist, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gist = gist {
                    completion(.success(gist))
                }
            }
        }
    }

    /**
     Edits an gist with a single file.
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter id: The of the gist to update.
     - parameter description: The description of the gist.
     - parameter filename: The name of the file in the gist.
     - parameter fileContent: The content of the file in the gist.
     - parameter completion: Callback for the gist that is created.
     */
    @discardableResult
    func patchGistFile(_ session: GitURLSession = URLSession.shared,
                       id: String,
                       description: String,
                       filename: String,
                       fileContent: String,
                       completion: @escaping (
                        _ response: Result<Gist, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = GistRouter.patchGistFile(configuration, id, description, filename, fileContent)
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session,
            decoder: decoder,
            expectedResultType: Gist.self) { gist, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let gist = gist {
                    completion(.success(gist))
                }
            }
        }
    }
}
