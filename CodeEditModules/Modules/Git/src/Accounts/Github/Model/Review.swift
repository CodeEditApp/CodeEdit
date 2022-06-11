//
//  Review.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// TODO: DOCS (Nanashi Li)
// swiftlint:disable missing_docs
public struct Review {
    public let body: String
    public let commitID: String
    public let id: Int
    public let state: State
    public let submittedAt: Date
    public let user: GithubUser
}

extension Review: Codable {
    enum CodingKeys: String, CodingKey {
        case body
        case commitID = "commit_id"
        case id
        case state
        case submittedAt = "submitted_at"
        case user
    }
}

public extension Review {
    enum State: String, Codable, Equatable {
        case approved = "APPROVED"
        case changesRequested = "CHANGES_REQUESTED"
        case comment = "COMMENTED"
        case dismissed = "DISMISSED"
        case pending = "PENDING"
    }
}

public extension GithubAccount {

    @discardableResult
    func listReviews(_ session: GitURLSession = URLSession.shared,
                     owner: String,
                     repository: String,
                     pullRequestNumber: Int,
                     completion: @escaping (
                        _ response: Result<[Review], Error>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = ReviewsRouter.listReviews(configuration, owner, repository, pullRequestNumber)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
            expectedResultType: [Review].self) { pullRequests, error in

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
