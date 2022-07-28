//
//  GitlabOAuthConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public struct GitlabOAuthConfiguration: Configuration {

    public var apiEndpoint: String?
    public var accessToken: String?
    public let token: String
    public let secret: String
    public let redirectURI: String
    public let webEndpoint: String
    public let errorDomain = "com.codeedit.models.accounts.gitlab"

    public init(_ url: String = gitlabBaseURL, webURL: String = gitlabWebURL,
                token: String, secret: String, redirectURI: String) {
        apiEndpoint = url
        webEndpoint = webURL
        self.token = token
        self.secret = secret
        self.redirectURI = redirectURI
    }

    public func authenticate() -> URL? {
        GitlabOAuthRouter.authorize(self, redirectURI).URLRequest?.url
    }

    public func authorize(_ session: GitURLSession = URLSession.shared,
                          code: String,
                          completion: @escaping (_ config: GitlabTokenConfiguration) -> Void) {
        let request = GitlabOAuthRouter.accessToken(self, code, redirectURI).URLRequest
        if let request = request {
            let task = session.dataTask(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        guard let data = data else {
                            return
                        }
                        do {
                            let json = try JSONSerialization.jsonObject(with: data,
                                                                        options: .allowFragments) as? [String: Any]
                            if let json = json, let accessToken = json["access_token"] as? String {
                                let config = GitlabTokenConfiguration(accessToken, url: self.apiEndpoint ?? "")
                                completion(config)
                            }
                        } catch {
                            return
                        }
                    }
                }
            }
            task.resume()
        }
    }

    public func handleOpenURL(_ session: GitURLSession = URLSession.shared,
                              url: URL,
                              completion: @escaping (_ config: GitlabTokenConfiguration) -> Void) {
        if let code = url.absoluteString.components(separatedBy: "=").last {
            authorize(session, code: code) { (config) in
                completion(config)
            }
        }
    }
}
