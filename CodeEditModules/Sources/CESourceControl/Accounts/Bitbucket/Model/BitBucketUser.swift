//
//  BitBucketUser.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
import SwiftUI

// TODO: DOCS (Nanashi Li)
class BitBucketUser: Codable {
    var id: String?
    var login: String?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case login = "username"
        case name = "display_name"
    }
}

class BitBucketEmail: Codable {
    var isPrimary: Bool
    var isConfirmed: Bool
    var type: String?
    var email: String?

    enum CodingKeys: String, CodingKey {
        case isPrimary = "is_primary"
        case isConfirmed = "is_confirmed"
        case type = "type"
        case email = "email"
    }
}

extension BitBucketAccount {

    /// Fetches the profile of the currently authenticated Bitbucket user.
    /// - Parameters:
    ///   - session: The session used to make the request; defaults to the shared session.
    ///   - completion: Called with the user on success, or the request error on failure.
    /// - Returns: The started network task, or `nil` if the request could not be constructed.
    public func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<BitBucketUser, Error>) -> Void
    ) -> GitURLSessionDataTaskProtocol? {

            let router = BitBucketUserRouter.readAuthenticatedUser(configuration)

            return router.load(
                session,
                dateDecodingStrategy: .formatted(GitTime.rfc3339DateFormatter),
                expectedResultType: BitBucketUser.self
            ) { user, error in
                if let error {
                    completion(.failure(error))
                } else {
                    if let user {
                        completion(.success(user))
                    }
                }
            }
        }

    func emails(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<BitBucketEmail, Error>) -> Void
    ) -> GitURLSessionDataTaskProtocol? {

            let router = BitBucketUserRouter.readEmails(configuration)

            return router.load(
                session,
                dateDecodingStrategy: .formatted(GitTime.rfc3339DateFormatter),
                expectedResultType: BitBucketEmail.self
            ) { email, error in
                if let error {
                    completion(.failure(error))
                } else {
                    if let email {
                        completion(.success(email))
                    }
                }
            }
    }
}
