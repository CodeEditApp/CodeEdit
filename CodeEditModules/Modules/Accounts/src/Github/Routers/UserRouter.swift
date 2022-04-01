//
//  UserRouter.swift
//  
//
//  Created by Nanshi Li on 2022/03/31.
//

import Foundation

enum UserRouter: Router {
    case readAuthenticatedUser(Configuration)
    case readUser(String, Configuration)

    var configuration: Configuration {
        switch self {
        case let .readAuthenticatedUser(config): return config
        case let .readUser(_, config): return config
        }
    }

    var method: HTTPMethod {
        return .GET
    }

    var encoding: HTTPEncoding {
        return .url
    }

    var path: String {
        switch self {
        case .readAuthenticatedUser:
            return "user"
        case let .readUser(username, _):
            return "users/\(username)"
        }
    }

    var params: [String: Any] {
        return [:]
    }
}
