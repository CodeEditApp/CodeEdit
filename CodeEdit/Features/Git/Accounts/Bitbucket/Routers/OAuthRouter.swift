//
//  OAuthRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum OAuthRouter: Router {
    case authorize(BitbucketOAuthConfiguration)
    case accessToken(BitbucketOAuthConfiguration, String)

    var configuration: RouterConfiguration? {
        switch self {
        case .authorize(let config): return config
        case .accessToken(let config, _): return config
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
            return "site/oauth2/authorize"
        case .accessToken:
            return "site/oauth2/access_token"
        }
    }

    var params: [String: Any] {
        switch self {
        case .authorize(let config):
            return ["client_id": config.token, "response_type": "code"]
        case .accessToken(_, let code):
            return ["code": code, "grant_type": "authorization_code"]
        }
    }

    var URLRequest: Foundation.URLRequest? {
        switch self {
        case .authorize(let config):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        case .accessToken(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}
