//
//  Repositories.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

open class Repository: Codable {
    open let id: String
    open let owner: User
    open var name: String?
    open var fullName: String?
    open var isPrivate: Bool
    open var repositoryDescription: String?
    open var gitURL: String?
    open var sshURL: String?
    open var cloneURL: String?
    open var size: Int
    open var scm: String?

    public init(json: [String: AnyObject]) {
        owner = User(json["owner"] as? [String: AnyObject] ?? [:])
        if let id = json["uuid"] as? String {
            self.id = id
            name = json["name"] as? String
            fullName = json["full_name"] as? String
            isPrivate = json["is_private"] as? Bool ?? false
            repositoryDescription = json["description"] as? String
            if let linksDict = json["links"] as? [String: AnyObject],
                let cloneArray = linksDict["clone"] as? [[String: String]] {
                for urlDict in cloneArray {
                    if urlDict["name"] == "https" {
                        let prefix = "https://\(owner.login ?? "")@"
                        gitURL = urlDict["href"]?.replacingOccurrences(of: prefix, with: "git://")
                        cloneURL = urlDict["href"]?.replacingOccurrences(of: prefix, with: "https://")
                    }
                    if urlDict["name"] == "ssh" {
                        sshURL = urlDict["href"]?.replacingOccurrences(of: "ssh://", with: "")
                    }
                }
            }
            size = json["size"] as? Int ?? 0
            scm = json["scm"] as? String
        } else {
            id = "-1"
            isPrivate = false
            size = 0
        }
    }
}

public enum PaginatedResponse<T> {
    case success(values: T, nextParameters: [String: String])
    case failure(Error)
}

public extension GitAccount {

    public func repositories(_ session: GitURLSession = URLSession.shared,
                             userName: String? = nil,
                             nextParameters: [String: String] = [:],
                             completion: @escaping (
                                _ response: PaginatedResponse<[Repository]>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = RepositoryRouter.readRepositories(configuration, userName, nextParameters)

        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(PaginatedResponse.failure(error))
            }

            if let json = json, let values = json["values"] as? [[String: AnyObject]] {
                let repos = values.map { Repository(json: $0) }
                if let nextURL = json["next"] as? String,
                    let parameterString = nextURL.components(separatedBy: "?").last {
                    completion(PaginatedResponse.success(values: repos,
                                                         nextParameters: parameterString.tkk_queryParameters))
                } else {
                    completion(PaginatedResponse.success(values: repos, nextParameters: [String: String]()))
                }
            }
        }
    }

    public func repository(_ session: GitURLSession = URLSession.shared,
                           owner: String,
                           name: String,
                           completion: @escaping (
                            _ response: Response<Repository>) -> Void) -> URLSessionDataTaskProtocol? {

        let router = RepositoryRouter.readRepository(configuration, owner, name)

        return router.loadJSON(session, expectedResultType: [String: AnyObject].self) { json, error in
            if let error = error {
                completion(Response.failure(error))
            }

            if let json = json {
                let repo =  Repository(json: json)
                completion(Response.success(repo))
            }
        }
    }
}
