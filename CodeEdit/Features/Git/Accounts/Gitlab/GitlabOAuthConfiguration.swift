//
//  GitLabOAuthConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

struct GitLabOAuthConfiguration: RouterConfiguration {

    var apiEndpoint: String?
    var accessToken: String?
    let token: String
    let secret: String
    let redirectURI: String
    let webEndpoint: String
    let errorDomain = "com.codeedit.models.accounts.gitlab"

    init(_ url: String = gitlabBaseURL, webURL: String = gitlabWebURL,
         token: String, secret: String, redirectURI: String
    ) {
        apiEndpoint = url
        webEndpoint = webURL
        self.token = token
        self.secret = secret
        self.redirectURI = redirectURI
    }

    func authenticate() -> URL? {
        GitLabOAuthRouter.authorize(self, redirectURI).URLRequest?.url
    }

    func authorize(_ session: GitURLSession = URLSession.shared,
                   code: String,
                   completion: @escaping (_ config: GitLabTokenConfiguration) -> Void
    ) {
        let request = GitLabOAuthRouter.accessToken(self, code, redirectURI).URLRequest
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
                                let config = GitLabTokenConfiguration(accessToken, url: self.apiEndpoint ?? "")
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

    func handleOpenURL(_ session: GitURLSession = URLSession.shared,
                       url: URL,
                       completion: @escaping (_ config: GitLabTokenConfiguration) -> Void
    ) {
        if let code = url.absoluteString.components(separatedBy: "=").last {
            authorize(session, code: code) { (config) in
                completion(config)
            }
        }
    }
}
