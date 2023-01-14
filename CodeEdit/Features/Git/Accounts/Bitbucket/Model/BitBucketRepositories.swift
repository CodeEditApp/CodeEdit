//
//  BitBucketRepositories.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

// TODO: DOCS (Nanashi Li)
class BitBucketRepositories: Codable {
    var id: String
    var owner: BitBucketUser
    var name: String?
    var fullName: String?
    var isPrivate: Bool
    var repositoryDescription: String?
    var gitURL: String?
    var sshURL: String?
    var cloneURL: String?
    var size: Int
    var scm: String?

    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case owner
        case name
        case fullName = "full_name"
        case isPrivate = "is_private"
        case repositoryDescription = "description"
        case gitURL = "git://"
        case sshURL = "ssh://"
        case cloneURL = "https://"
        case size
        case scm
    }
}

enum BitbucketPaginatedResponse<T> {
    case success(values: T, nextParameters: [String: String])
    case failure(Error)
}

extension BitBucketAccount {

    func repositories(
        _ session: GitURLSession = URLSession.shared,
        userName: String? = nil,
        nextParameters: [String: String] = [:],
        completion: @escaping (_ response: BitbucketPaginatedResponse<[BitBucketRepositories]>) -> Void
    ) -> GitURLSessionDataTaskProtocol? {
        let router = BitBucketRepositoryRouter.readRepositories(configuration, userName, nextParameters)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(GitTime.rfc3339DateFormatter),
            expectedResultType: BitBucketRepositories.self
        ) { repo, error in

            if let error = error {
                completion(BitbucketPaginatedResponse.failure(error))
            } else {
                if let repo = repo {
                    completion(BitbucketPaginatedResponse.success(values: [repo], nextParameters: [:]))
                }
            }
        }
    }

    func repository(
        _ session: GitURLSession = URLSession.shared,
        owner: String,
        name: String,
        completion: @escaping (_ response: Result<BitBucketRepositories, Error>) -> Void
    ) -> GitURLSessionDataTaskProtocol? {
        let router = BitBucketRepositoryRouter.readRepository(configuration, owner, name)

        return router.load(
            session,
            dateDecodingStrategy: .formatted(GitTime.rfc3339DateFormatter),
            expectedResultType: BitBucketRepositories.self
        ) { data, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let data = data {
                completion(Result.success(data))
            }
        }
    }
}
