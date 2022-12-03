//
//  Issue.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanshi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class Issue: Codable {
    private(set) var id: Int = -1
    var url: URL?
    var repositoryURL: URL?
    @available(*, deprecated)
    var labelsURL: URL?
    var commentsURL: URL?
    var eventsURL: URL?
    var htmlURL: URL?
    var number: Int
    var state: Openness?
    var title: String?
    var body: String?
    var user: GitHubUser?
    var assignee: GitHubUser?
    var locked: Bool?
    var comments: Int?
    var closedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var closedBy: GitHubUser?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case repositoryURL = "repository_url"
        case commentsURL = "comments_url"
        case eventsURL = "events_url"
        case htmlURL = "html_url"
        case number
        case state
        case title
        case body
        case user
        case assignee
        case locked
        case comments
        case closedAt = "closed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case closedBy = "closed_by"
    }
}

extension GitHubAccount {
    /**
     Fetches the issues of the authenticated user
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter state: Issue state. Defaults to open if not specified.
     - parameter page: Current page for issue pagination. `1` by default.
     - parameter perPage: Number of issues per page. `100` by default.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func myIssues(_ session: GitURLSession = URLSession.shared,
                  state: Openness = .open,
                  page: String = "1",
                  perPage: String = "100",
                  completion: @escaping (_ response: Result<[Issue], Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = IssueRouter.readAuthenticatedIssues(configuration, page, perPage, state)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Issue].self) { issues, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issues = issues {
                    completion(.success(issues))
                }
            }
        }
    }

    /**
     Fetches an issue in a repository
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter number: The number of the issue.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func issue(_ session: GitURLSession = URLSession.shared,
               owner: String, repository: String,
               number: Int,
               completion: @escaping (
                _ response: Result<Issue, Error>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = IssueRouter.readIssue(configuration, owner, repository, number)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: Issue.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }

    /**
     Fetches all issues in a repository
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter state: Issue state. Defaults to open if not specified.
     - parameter page: Current page for issue pagination. `1` by default.
     - parameter perPage: Number of issues per page. `100` by default.
     - parameter completion: Callback for the outcome of the fetch.
     */
    @discardableResult
    func issues(_ session: GitURLSession = URLSession.shared,
                owner: String,
                repository: String,
                state: Openness = .open,
                page: String = "1",
                perPage: String = "100",
                completion: @escaping (
                    _ response: Result<[Issue], Error>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = IssueRouter.readIssues(configuration, owner, repository, page, perPage, state)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Issue].self) { issues, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issues = issues {
                    completion(.success(issues))
                }
            }
        }
    }

    /**
     Creates an issue in a repository.
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter title: The title of the issue.
     - parameter body: The body text of the issue in GitHub-flavored Markdown format.
     - parameter assignee: The name of the user to assign the issue to.
                           This parameter is ignored if the user lacks push access to the repository.
     - parameter labels: An array of label names to add to the issue. If the labels do not exist,
                         GitHub will create them automatically.
                         This parameter is ignored if the user lacks push access to the repository.
     - parameter completion: Callback for the issue that is created.
     */
    @discardableResult
    func postIssue(_ session: GitURLSession = URLSession.shared,
                   owner: String,
                   repository: String,
                   title: String,
                   body: String? = nil,
                   assignee: String? = nil,
                   labels: [String] = [],
                   completion: @escaping (
                    _ response: Result<Issue, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.postIssue(configuration, owner, repository, title, body, assignee, labels)
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session,
            decoder: decoder,
            expectedResultType: Issue.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }

    /**
     Edits an issue in a repository.
     - parameter session: GitURLSession, defaults to URLSession.sharedSession()
     - parameter owner: The user or organization that owns the repository.
     - parameter repository: The name of the repository.
     - parameter number: The number of the issue.
     - parameter title: The title of the issue.
     - parameter body: The body text of the issue in GitHub-flavored Markdown format.
     - parameter assignee: The name of the user to assign the issue to.
                           This parameter is ignored if the user lacks push access to the repository.
     - parameter state: Whether the issue is open or closed.
     - parameter completion: Callback for the issue that is created.
     */
    @discardableResult
    func patchIssue(_ session: GitURLSession = URLSession.shared,
                    owner: String,
                    repository: String,
                    number: Int,
                    title: String? = nil,
                    body: String? = nil,
                    assignee: String? = nil,
                    state: Openness? = nil,
                    completion: @escaping (
                        _ response: Result<Issue, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.patchIssue(configuration, owner, repository, number, title, body, assignee, state)

        return router.post(
            session,
            expectedResultType: Issue.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }

    /// Posts a comment on an issue using the given body.
    /// - Parameters:
    ///   - session: GitURLSession, defaults to URLSession.sharedSession()
    ///   - owner: The user or organization that owns the repository.
    ///   - repository: The name of the repository.
    ///   - number: The number of the issue.
    ///   - body: The contents of the comment.
    ///   - completion: Callback for the comment that is created.
    @discardableResult
    func commentIssue(_ session: GitURLSession = URLSession.shared,
                      owner: String,
                      repository: String,
                      number: Int,
                      body: String,
                      completion: @escaping (
                        _ response: Result<Comment, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.commentIssue(configuration, owner, repository, number, body)
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session,
            decoder: decoder,
            expectedResultType: Comment.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }

    /// Fetches all comments for an issue
    /// - Parameters:
    /// - session: GitURLSession, defaults to URLSession.sharedSession()
    /// - owner: The user or organization that owns the repository.
    /// - repository: The name of the repository.
    /// - number: The number of the issue.
    /// - page: Current page for comments pagination. `1` by default.
    /// - perPage: Number of comments per page. `100` by default.
    /// - completion: Callback for the outcome of the fetch.
    @discardableResult
    func issueComments(_ session: GitURLSession = URLSession.shared,
                       owner: String,
                       repository: String,
                       number: Int,
                       page: String = "1",
                       perPage: String = "100",
                       completion: @escaping (
                        _ response: Result<[Comment], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.readIssueComments(configuration, owner, repository, number, page, perPage)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Comment].self) { comments, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let comments = comments {
                    completion(.success(comments))
                }
            }
        }
    }

    /// Edits a comment on an issue using the given body.
    /// - Parameters:
    ///   - session: GitURLSession, defaults to URLSession.sharedSession()
    ///   - owner: The user or organization that owns the repository.
    ///   - repository: The name of the repository.
    ///   - number: The number of the comment.
    ///   - body: The contents of the comment.
    ///   - completion: Callback for the comment that is created.
    @discardableResult
    func patchIssueComment(
        _ session: GitURLSession = URLSession.shared,
        owner: String,
        repository: String,
        number: Int,
        body: String,
        completion: @escaping (
            _ response: Result<Comment, Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = IssueRouter.patchIssueComment(configuration, owner, repository, number, body)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Time.rfc3339DateFormatter)

        return router.post(
            session, decoder: decoder,
            expectedResultType: Comment.self) { issue, error in

            if let error = error {
                completion(.failure(error))
            } else {
                if let issue = issue {
                    completion(.success(issue))
                }
            }
        }
    }
}
