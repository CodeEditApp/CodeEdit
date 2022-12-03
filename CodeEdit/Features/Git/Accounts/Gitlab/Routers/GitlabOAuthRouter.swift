//
//  GitLabOAuthRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum GitLabOAuthRouter: Router {
    case authorize(GitLabOAuthConfiguration, String)
    case accessToken(GitLabOAuthConfiguration, String, String)

    var configuration: RouterConfiguration? {
        switch self {
        case .authorize(let config, _): return config
        case .accessToken(let config, _, _): return config
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
            return "oauth/authorize"
        case .accessToken:
            return "oauth/token"
        }
    }

    var params: [String: Any] {
        switch self {
        case let .authorize(config, redirectURI):
            return [
                "client_id": config.token as AnyObject,
                "response_type": "code" as AnyObject,
                "redirect_uri": redirectURI as AnyObject]
        case let .accessToken(config, code, rediredtURI):
            return [
                "client_id": config.token as AnyObject,
                "client_secret": config.secret as AnyObject,
                "code": code as AnyObject, "grant_type":
                    "authorization_code" as AnyObject,
                "redirect_uri": rediredtURI as AnyObject]
        }
    }

    var URLRequest: Foundation.URLRequest? {
        switch self {
        case .authorize(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        case .accessToken(let config, _, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}
