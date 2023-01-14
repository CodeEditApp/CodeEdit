//
//  GitHubReview.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// TODO: DOCS (Nanashi Li)
struct GitHubReview {
    let body: String
    let commitID: String
    let id: Int
    let state: State
    let submittedAt: Date
    let user: GitHubUser
}

extension GitHubReview: Codable {
    enum CodingKeys: String, CodingKey {
        case body
        case commitID = "commit_id"
        case id
        case state
        case submittedAt = "submitted_at"
        case user
    }
}

extension GitHubReview {
    enum State: String, Codable, Equatable {
        case approved = "APPROVED"
        case changesRequested = "CHANGES_REQUESTED"
        case comment = "COMMENTED"
        case dismissed = "DISMISSED"
        case pending = "PENDING"
    }
}

extension GitHubAccount {

    @discardableResult
    func listReviews(
        _ session: GitURLSession = URLSession.shared,
        owner: String,
        repository: String,
        pullRequestNumber: Int,
        completion: @escaping (_ response: Result<[GitHubReview], Error>) -> Void
    ) -> GitURLSessionDataTaskProtocol? {
        let router = GitHubReviewsRouter.listReviews(configuration, owner, repository, pullRequestNumber)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(GitTime.rfc3339DateFormatter),
            expectedResultType: [GitHubReview].self
        ) { pullRequests, error in

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
