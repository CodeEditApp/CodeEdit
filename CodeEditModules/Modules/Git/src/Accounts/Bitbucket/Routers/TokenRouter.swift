//
//  TokenRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public enum TokenRouter: Router {
    case refreshToken(BitbucketOAuthConfiguration, String)
    case emptyToken(BitbucketOAuthConfiguration, String)

    public var configuration: Configuration? {
        switch self {
        case .refreshToken(let config, _): return config
        default: return nil
        }
    }

    public var method: HTTPMethod {
        .POST
    }

    public var encoding: HTTPEncoding {
        .form
    }

    public var params: [String: Any] {
        switch self {
        case .refreshToken(_, let token):
            return ["refresh_token": token, "grant_type": "refresh_token"]
        default: return ["": ""]
        }
    }

    public var path: String {
        switch self {
        case .refreshToken:
            return "site/oauth2/access_token"
        default: return ""
        }
    }

    public var URLRequest: Foundation.URLRequest? {
        switch self {
        case .refreshToken(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        default: return nil
        }
    }
}
