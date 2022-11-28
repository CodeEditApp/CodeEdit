//
//  GitHubConfiguration.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct GitHubTokenConfiguration: RouterConfiguration {
    var apiEndpoint: String?
    var accessToken: String?
    let errorDomain: String? = "com.codeedit.models.accounts.github"
    let authorizationHeader: String? = "Basic"

    /// Custom `Accept` header for API previews.
    ///
    /// Used for preview support of new APIs, for instance Reaction API.
    /// see: https://developer.github.com/changes/2016-05-12-reactions-api-preview/
    private var previewCustomHeaders: [HTTPHeader]?

    var customHeaders: [HTTPHeader]? {
        /// More (non-preview) headers can be appended if needed in the future
        return previewCustomHeaders
    }

    init(_ token: String? = nil, url: String = githubBaseURL, previewHeaders: [PreviewHeader] = []) {
        apiEndpoint = url
        accessToken = token?.data(using: .utf8)!.base64EncodedString()
        previewCustomHeaders = previewHeaders.map { $0.header }
    }
}

struct OAuthConfiguration: RouterConfiguration {
    var apiEndpoint: String?
    var accessToken: String?
    let token: String
    let secret: String
    let scopes: [String]
    let webEndpoint: String
    let errorDomain = "com.codeedit.models.accounts.github"

    /// Custom `Accept` header for API previews.
    ///
    /// Used for preview support of new APIs, for instance Reaction API.
    /// see: https://developer.github.com/changes/2016-05-12-reactions-api-preview/
    private var previewCustomHeaders: [HTTPHeader]?

    var customHeaders: [HTTPHeader]? {
        /// More (non-preview) headers can be appended if needed in the future
        return previewCustomHeaders
    }

    init(_ url: String = githubBaseURL, webURL: String = githubWebURL,
         token: String, secret: String, scopes: [String], previewHeaders: [PreviewHeader] = []
    ) {
        apiEndpoint = url
        webEndpoint = webURL
        self.token = token
        self.secret = secret
        self.scopes = scopes
        previewCustomHeaders = previewHeaders.map { $0.header }
    }

    func authenticate() -> URL? {
        GitHubOAuthRouter.authorize(self).URLRequest?.url
    }

    func authorize(
        _ session: GitURLSession = URLSession.shared,
        code: String,
        completion: @escaping (_ config: GitHubTokenConfiguration) -> Void) {

        let request = GitHubOAuthRouter.accessToken(self, code).URLRequest
        if let request = request {
            let task = session.dataTask(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else {
                        if let data = data, let string = String(data: data, encoding: .utf8) {
                            let accessToken = self.accessTokenFromResponse(string)
                            if let accessToken = accessToken {
                                let config = GitHubTokenConfiguration(accessToken, url: self.apiEndpoint ?? "")
                                completion(config)
                            }
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func handleOpenURL(
        _ session: GitURLSession = URLSession.shared,
        url: URL,
        completion: @escaping (_ config: GitHubTokenConfiguration) -> Void) {

        if let code = url.URLParameters["code"] {
            authorize(session, code: code) { config in
                completion(config)
            }
        }
    }

    func accessTokenFromResponse(_ response: String) -> String? {
        let accessTokenParam = response.components(separatedBy: "&").first
        if let accessTokenParam = accessTokenParam {
            return accessTokenParam.components(separatedBy: "=").last
        }
        return nil
    }
}

enum GitHubOAuthRouter: Router {
    case authorize(OAuthConfiguration)
    case accessToken(OAuthConfiguration, String)

    var configuration: RouterConfiguration? {
        switch self {
        case let .authorize(config): return config
        case let .accessToken(config, _): return config
        }
    }

    var method: HTTPMethod {
        switch self {
        case .authorize:
            return .GET
        case .accessToken:
            return .POST
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .authorize:
            return .url
        case .accessToken:
            return .form
        }
    }

    var path: String {
        switch self {
        case .authorize:
            return "login/oauth/authorize"
        case .accessToken:
            return "login/oauth/access_token"
        }
    }

    var params: [String: Any] {
        switch self {
        case let .authorize(config):
            let scope = (config.scopes as NSArray).componentsJoined(by: ",")
            return ["scope": scope, "client_id": config.token, "allow_signup": "false"]
        case let .accessToken(config, code):
            return ["client_id": config.token, "client_secret": config.secret, "code": code]
        }
    }

    #if canImport(FoundationNetworking)
    typealias FoundationURLRequestType = FoundationNetworking.URLRequest
    #else
    typealias FoundationURLRequestType = Foundation.URLRequest
    #endif

    var URLRequest: FoundationURLRequestType? {
        switch self {
        case let .authorize(config):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        case let .accessToken(config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}
