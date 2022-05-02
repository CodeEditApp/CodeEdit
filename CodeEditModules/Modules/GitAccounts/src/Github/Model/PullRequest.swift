//
//  PullRequest.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

open class PullRequest: Codable {
    open private(set) var id: Int = -1
    open var url: URL?

    open var htmlURL: URL?
    open var diffURL: URL?
    open var patchURL: URL?
    open var issueURL: URL?
    open var commitsURL: URL?
    open var reviewCommentsURL: URL?
    open var reviewCommentURL: URL?
    open var commentsURL: URL?
    open var statusesURL: URL?

    open var title: String?
    open var body: String?

    open var assignee: GithubUser?

    open var locked: Bool?
    open var createdAt: Date?
    open var updatedAt: Date?
    open var closedAt: Date?
    open var mergedAt: Date?

    open var user: GithubUser?
    open var number: Int
    open var state: Openness?

    open var head: PullRequest.Branch?
    open var base: PullRequest.Branch?

    open var requestedReviewers: [GithubUser]?
    open var draft: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case diffURL = "diff_url"
        case patchURL = "patch_url"
        case issueURL = "issue_url"
        case commitsURL = "commits_url"
        case reviewCommentsURL = "review_comments_url"
        case commentsURL = "comments_url"
        case statusesURL = "statuses_url"
        case htmlURL = "html_url"
        case number
        case state
        case title
        case body
        case assignee
        case locked
        case user
        case closedAt = "closed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case mergedAt = "merged_at"
        case head
        case base
        case requestedReviewers = "requested_reviewers"
        case draft
    }

    open class Branch: Codable {
        open var label: String?
        open var ref: String?
        open var sha: String?
        open var user: GithubUser?
        open var repo: GithubRepositories?
    }
}

public extension GithubAccount {

    /**
     Get a single pull request
     - parameter session: GitURLSession, defaults to URLSession.shared
     - parameter owner: The user or organization that owns the repositories.
     - parameter repository: The name of the repository.
     - parameter number: The number of the PR to fetch.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func pullRequest(_ session: GitURLSession = URLSession.shared,
                     owner: String,
                     repository: String,
                     number: Int,
                     completion: @escaping (
                        _ response: Result<PullRequest, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = PullRequestRouter.readPullRequest(configuration, owner, repository, "\(number)")

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: PullRequest.self) { pullRequest, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let pullRequest = pullRequest {
                    completion(.success(pullRequest))
                }
            }
        }
    }

    /**
     Get a list of pull requests
     - parameter session: GitURLSession, defaults to URLSession.shared
     - parameter owner: The user or organization that owns the repositories.
     - parameter repository: The name of the repository.
     - parameter base: Filter pulls by base branch name.
     - parameter head: Filter pulls by user or organization and branch name.
     - parameter state: Filter pulls by their state.
     - parameter direction: The direction of the sort.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func pullRequests(_ session: GitURLSession = URLSession.shared,
                      owner: String,
                      repository: String,
                      base: String? = nil,
                      head: String? = nil,
                      state: Openness = .open,
                      sort: SortType = .created,
                      direction: SortDirection = .desc,
                      completion: @escaping (
                        _ response: Result<[PullRequest], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = PullRequestRouter.readPullRequests(
            configuration,
            owner,
            repository,
            base,
            head,
            state,
            sort,
            direction)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [PullRequest].self) { pullRequests, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let pullRequests = pullRequests {
                    completion(.success(pullRequests))
                }
            }
        }
    }
}
