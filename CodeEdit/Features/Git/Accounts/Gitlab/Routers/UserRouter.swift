//
//  UserRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum UserRouter: Router {
    case readAuthenticatedUser(RouterConfiguration)

    var configuration: RouterConfiguration? {
        switch self {
        case .readAuthenticatedUser(let config): return config
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
        }
    }

    var params: [String: Any] {
        [:]
    }
}
