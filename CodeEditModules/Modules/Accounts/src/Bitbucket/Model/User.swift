//
//  User.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class User: Codable {
    open let id: String
    open var login: String?
    open var name: String?

    public init(_ json: [String: AnyObject]) {
        if let id = json["uuid"] as? String {
            self.id = id
            login = json["username"] as? String
            name = json["display_name"] as? String
        } else {
            id = "-1"
        }
    }
}

open class Email: Codable {
    open let isPrimary: Bool
    open let isConfirmed: Bool
    open var type: String?
    open var email: String?

    public init(json: [String: AnyObject]) {
        if let != nil json["email"] as? String {
            isPrimary = json["is_primary"] as? Bool ?? false
            isConfirmed = json["is_confirmed"] as? Bool ?? false
            type = json["type"] as? String
            email = json["email"] as? String
        } else {
            isPrimary = false
            isConfirmed = false
        }
        super.init()
    }
}

public extension GitAccount {

    public func me(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Response<User>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = UserRouter.readAuthenticatedUser(configuration)

        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json {
                    let parsedUser = User(json)
                    completion(Response.success(parsedUser))
                }
            }
        }
    }

    public func emails(
        _ session: GitURLSession = URLSession.shared,
        completion: @escaping (_ response: Response<[Email]>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = UserRouter.readEmails(configuration)

        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            } else {
                if let json = json, let values = json["values"] as? [[String: AnyObject]] {
                    let emails = values.map({ Email(json: $0) })
                    completion(Response.success(emails))
                }
            }
        }
    }
}
