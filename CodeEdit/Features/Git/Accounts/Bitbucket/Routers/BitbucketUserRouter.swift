//
//  BitbucketUserRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum BitbucketUserRouter: Router {
    case readAuthenticatedUser(RouterConfiguration)
    case readEmails(RouterConfiguration)

    var configuration: RouterConfiguration? {
        switch self {
        case .readAuthenticatedUser(let config): return config
        case .readEmails(let config): return config
        }
    }

    var method: HTTPMethod {
        .GET
    }

    var encoding: HTTPEncoding {
        .url
    }

    var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case .readEmails:
            return "user/emails"
        }
    }

    var params: [String: Any] {
        [:]
    }
}
