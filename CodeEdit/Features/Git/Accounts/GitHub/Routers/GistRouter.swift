//
//  GistRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanshi Li on 2022/03/31.
//

import Foundation

enum GistRouter: JSONPostRouter {
    case readAuthenticatedGists(RouterConfiguration, String, String)
    case readGists(RouterConfiguration, String, String, String)
    case readGist(RouterConfiguration, String)
    case postGistFile(RouterConfiguration, String, String, String, Bool)
    case patchGistFile(RouterConfiguration, String, String, String, String)

    var method: HTTPMethod {
        switch self {
        case .postGistFile, .patchGistFile:
            return .POST
        default:
            return .GET
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .postGistFile, .patchGistFile:
            return .json
        default:
            return .url
        }
    }

    var configuration: RouterConfiguration? {
        switch self {
        case let .readAuthenticatedGists(config, _, _): return config
        case let .readGists(config, _, _, _): return config
        case let .readGist(config, _): return config
        case let .postGistFile(config, _, _, _, _): return config
        case let .patchGistFile(config, _, _, _, _): return config
        }
    }

    var params: [String: Any] {
        switch self {
        case let .readAuthenticatedGists(_, page, perPage):
            return ["per_page": perPage, "page": page]
        case let .readGists(_, _, page, perPage):
            return ["per_page": perPage, "page": page]
        case .readGist:
            return [:]
        case let .postGistFile(_, description, filename, fileContent, publicAccess):
            var params = [String: Any]()
            params["public"] = publicAccess
            params["description"] = description
            var file = [String: Any]()
            file["content"] = fileContent
            var files = [String: Any]()
            files[filename] = file
            params["files"] = files
            return params
        case let .patchGistFile(_, _, description, filename, fileContent):
            var params = [String: Any]()
            params["description"] = description
            var file = [String: Any]()
            file["content"] = fileContent
            var files = [String: Any]()
            files[filename] = file
            params["files"] = files
            return params
        }
    }

    var path: String {
        switch self {
        case .readAuthenticatedGists:
            return "gists"
        case let .readGists(_, owner, _, _):
            return "users/\(owner)/gists"
        case let .readGist(_, id):
            return "gists/\(id)"
        case .postGistFile:
            return "gists"
        case let .patchGistFile(_, id, _, _, _):
            return "gists/\(id)"
        }
    }
}
