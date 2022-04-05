//
//  UserRouter.swift
//  
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum UserRouter: Router {
    case readAuthenticatedUser(Configuration)

    var configuration: Configuration? {
        switch self {
        case .readAuthenticatedUser(let config): return config
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
        }
    }

    var params: [String: Any] {
        return [:]
    }
}
