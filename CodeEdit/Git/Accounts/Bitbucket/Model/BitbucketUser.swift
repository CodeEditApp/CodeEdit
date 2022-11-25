//
//  BitbucketUser.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
import SwiftUI

// TODO: DOCS (Nanashi Li)
class BitbucketUser: Codable {
    var id: String?
    var login: String?
    var name: String?

    enum CodingKeys: String, CodingKey {
        case id
        case login = "username"
        case name = "display_name"
    }
}

class Email: Codable {
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

extension BitbucketAccount {

    func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Result<BitbucketUser, Error>) -> Void) -> URLSessionDataTaskProtocol? {

            let router = BitbucketUserRouter.readAuthenticatedUser(configuration)

            return router.load(session,
                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                               expectedResultType: BitbucketUser.self) { user, error in
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
        completion: @escaping (_ response: Result<Email, Error>) -> Void) -> URLSessionDataTaskProtocol? {

            let router = BitbucketUserRouter.readEmails(configuration)

            return router.load(session,
                               dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                               expectedResultType: Email.self) { email, error in
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
