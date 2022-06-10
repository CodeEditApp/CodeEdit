//
//  BitbucketUserRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public enum BitbucketUserRouter: Router {
    case readAuthenticatedUser(Configuration)
    case readEmails(Configuration)

    public var configuration: Configuration? {
        switch self {
        case .readAuthenticatedUser(let config): return config
        case .readEmails(let config): return config
        }
    }

    public var method: HTTPMethod {
        .GET
    }

    public var encoding: HTTPEncoding {
        .url
    }

    public var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case .readEmails:
            return "user/emails"
        }
    }

    public var params: [String: Any] {
        [:]
    }
}
