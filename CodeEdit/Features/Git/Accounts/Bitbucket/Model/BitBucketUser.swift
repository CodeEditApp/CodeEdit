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

    func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<BitBucketUser, Error>) -> Void
    ) -> GitURLSessionDataTaskProtocol? {

            let router = BitBucketUserRouter.readAuthenticatedUser(configuration)

            return router.load(
                session,
                dateDecodingStrategy: .formatted(GitTime.rfc3339DateFormatter),
                expectedResultType: BitBucketUser.self
            ) { user, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let user = user {
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
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let email = email {
                        completion(.success(email))
                    }
                }
            }
    }
}
