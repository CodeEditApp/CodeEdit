//
//  GitlabCommit.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class GitlabCommit: Codable {
    open var id: String
    open var shortID: String?
    open var title: String?
    open var authorName: String?
    open var authorEmail: String?
    open var committerName: String?
    open var committerEmail: String?
    open var createdAt: Date?
    open var message: String?
    open var committedDate: Date?
    open var authoredDate: Date?
    open var parentIDs: [String]?
    open var stats: CommitStats?
    open var status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case shortID = "short_id"
        case title
        case authorName = "author_name"
        case authorEmail = "author_email"
        case committerName = "committer_name"
        case committerEmail = "committer_email"
        case createdAt = "created_at"
        case message
        case committedDate = "committed_date"
        case authoredDate = "authored_date"
        case parentIDs = "parent_ids"
        case stats
        case status
    }
}

open class CommitStats: Codable {
    open var additions: Int?
    open var deletions: Int?
    open var total: Int?

    enum CodingKeys: String, CodingKey {
        case additions
        case deletions
        case total
    }
}

open class CommitDiff: Codable {
    open var diff: String?
    open var newPath: String?
    open var oldPath: String?
    open var aMode: String?
    open var bMode: String?
    open var newFile: Bool?
    open var renamedFile: Bool?
    open var deletedFile: Bool?

    enum CodingKeys: String, CodingKey {
        case diff
        case newPath = "new_path"
        case oldPath = "old_path"
        case aMode = "a_mode"
        case bMode = "b_mode"
        case newFile = "new_file"
        case renamedFile = "renamed_file"
        case deletedFile = "deleted_file"
    }
}

open class CommitComment: Codable {
    open var note: String?
    open var author: GitlabUser?

    enum CodingKeys: String, CodingKey {
        case note
        case author
    }
}

open class CommitStatus: Codable {
    open var status: String?
    open var createdAt: Date?
    open var startedAt: Date?
    open var name: String?
    open var allowFailure: Bool?
    open var author: GitlabUser?
    open var statusDescription: String?
    open var sha: String?
    open var targetURL: URL?
    open var finishedAt: Date?
    open var id: Int?
    open var ref: String?

    enum CodingKeys: String, CodingKey {
        case status
        case createdAt = "created_at"
        case startedAt = "started_at"
        case name
        case allowFailure = "allow_failure"
        case author
        case statusDescription = "description"
        case sha
        case targetURL = "target_url"
        case finishedAt = "finished_at"
        case id
        case ref
    }
}

public extension GitlabAccount {

    /**
     Get a list of repository commits in a project.
     - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
     - parameter refName: The name of a repository branch or tag or if not given the default branch.
     - parameter since: Only commits after or in this date will be returned in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ.
     - parameter until: Only commits before or in this date will be returned in ISO 8601 format YYYY-MM-DDTHH:MM:SSZ.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func commits(_ session: GitURLSession = URLSession.shared,
                 id: String,
                 refName: String = "",
                 since: String = "",
                 until: String = "",
                 completion: @escaping (
                    _ response: Result<GitlabCommit, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                        let router = CommitRouter.readCommits(self.configuration,
                                                              id: id,
                                                              refName: refName,
                                                              since: since,
                                                              until: until)

                        return router.load(session,
                                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                           expectedResultType: GitlabCommit.self) { json, error in

                            if let error = error {
                                completion(Result.failure(error))
                            }

                            if let json = json {
                                completion(Result.success(json))
                            }
                        }
                    }

    /**
     Get a specific commit in a project.
     - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
     - parameter sha: The commit hash or name of a repository branch or tag.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func commit(_ session: GitURLSession = URLSession.shared,
                id: String,
                sha: String,
                completion: @escaping (
                    _ response: Result<GitlabCommit, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                        let router = CommitRouter.readCommit(self.configuration, id: id, sha: sha)

                        return router.load(session,
                                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                           expectedResultType: GitlabCommit.self) { json, error in

                            if let error = error {
                                completion(Result.failure(error))
                            }

                            if let json = json {
                                completion(Result.success(json))
                            }
                        }
                    }

    /**
     Get a diff of a commit in a project.
     - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
     - parameter sha: The commit hash or name of a repository branch or tag.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func commitDiffs(_ session: GitURLSession = URLSession.shared,
                     id: String,
                     sha: String,
                     completion: @escaping (
                        _ response: Result<CommitDiff, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                            let router = CommitRouter.readCommitDiffs(self.configuration, id: id, sha: sha)

                            return router.load(session,
                                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                               expectedResultType: CommitDiff.self) { json, error in

                                if let error = error {
                                    completion(Result.failure(error))
                                }

                                if let json = json {
                                    completion(Result.success(json))
                                }
                            }
                        }

    /**
     Get the comments of a commit in a project.
     - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
     - parameter sha: The commit hash or name of a repository branch or tag.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func commitComments(_ session: GitURLSession = URLSession.shared,
                        id: String,
                        sha: String,
                        completion: @escaping (
                            _ response: Result<CommitComment, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                                let router = CommitRouter.readCommitComments(self.configuration, id: id, sha: sha)

                                return router.load(session,
                                                   dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                                   expectedResultType: CommitComment.self) { json, error in

                                    if let error = error {
                                        completion(Result.failure(error))
                                    }

                                    if let json = json {
                                        completion(Result.success(json))
                                    }
                                }
                            }

    /**
     Get the statuses of a commit in a project.
     - parameter id: The ID of a project or namespace/project name owned by the authenticated user.
     - parameter sha: The commit hash or name of a repository branch or tag.
     - parameter ref: The name of a repository branch or tag or, if not given, the default branch.
     - parameter stage: Filter by build stage, e.g. `test`.
     - parameter name: Filter by job name, e.g. `bundler:audit`.
     - parameter all: Return all statuses, not only the latest ones. (Boolean value)
     - parameter completion: Callback for the outcome of the fetch.
     */
    func commitStatuses(_ session: GitURLSession = URLSession.shared,
                        id: String,
                        sha: String,
                        ref: String = "",
                        stage: String = "",
                        name: String = "",
                        all: Bool = false,
                        completion: @escaping (
                            _ response: Result<CommitStatus, Error>) -> Void) -> URLSessionDataTaskProtocol? {

                                let router = CommitRouter.readCommitStatuses(self.configuration, id: id,
                                                                             sha: sha,
                                                                             ref: ref,
                                                                             stage: stage,
                                                                             name: name,
                                                                             all: all)

                                return router.load(session,
                                                   dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                                                   expectedResultType: CommitStatus.self) { json, error in

                                    if let error = error {
                                        completion(Result.failure(error))
                                    }

                                    if let json = json {
                                        completion(Result.success(json))
                                    }
                                }
                            }
}
