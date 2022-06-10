//
//  ProjectRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

public enum Visibility: String {
    case visbilityPublic = "public"
    case visibilityInternal = "interal"
    case visibilityPrivate = "private"
    case all = ""
}

public enum OrderBy: String {
    case id = "id"
    case name = "name"
    case path = "path"
    case creationDate = "created_at"
    case updateDate = "updated_at"
    case lastActvityDate = "last_activity_at"
}

public enum Sort: String {
    case ascending = "asc"
    case descending = "desc"
}

enum ProjectRouter: Router {
    case readAuthenticatedProjects(
        configuration: Configuration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readVisibleProjects(
        configuration: Configuration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readOwnedProjects(
        configuration: Configuration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readStarredProjects(
        configuration: Configuration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readAllProjects(
        configuration: Configuration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readSingleProject(configuration: Configuration, id: String)
    case readProjectEvents(configuration: Configuration, id: String, page: String, perPage: String)
    case readProjectHooks(configuration: Configuration, id: String)
    case readProjectHook(configuration: Configuration, id: String, hookId: String)

    var configuration: Configuration? {
        switch self {
        case .readAuthenticatedProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readVisibleProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readOwnedProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readStarredProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readAllProjects(let config, _, _, _, _, _, _, _, _): return config
        case .readSingleProject(let config, _): return config
        case .readProjectEvents(let config, _, _, _): return config
        case .readProjectHooks(let config, _): return config
        case .readProjectHook(let config, _, _): return config
        }
    }

    var method: HTTPMethod {
        .GET
    }

    var encoding: HTTPEncoding {
        .url
    }

    var params: [String: Any] {
        switch self {
        case .readAuthenticatedProjects(
            _,
            let page,
            let perPage,
            let archived,
            let visibility,
            let orderBy,
            let sort,
            let search,
            let simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case .readVisibleProjects(
            _,
            let page,
            let perPage,
            let archived,
            let visibility,
            let orderBy,
            let sort,
            let search,
            let simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case .readOwnedProjects(
            _, let page,
            let perPage,
            let archived,
            let visibility,
            let orderBy,
            let sort,
            let search,
            let simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case .readStarredProjects(
            _,
            let page,
            let perPage,
            let archived,
            let visibility,
            let orderBy,
            let sort,
            let search,
            let simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case .readAllProjects(
            _,
            let page,
            let perPage,
            let archived,
            let visibility,
            let orderBy,
            let sort,
            let search,
            let simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case .readSingleProject:
            return [:]
        case .readProjectEvents(_, _, let page, let perPage):
            return ["per_page": perPage, "page": page]
        case .readProjectHooks:
            return [:]
        case .readProjectHook:
            return [:]
        }
    }

    var path: String {
        switch self {
        case .readAuthenticatedProjects:
            return "projects"
        case .readVisibleProjects:
            return "projects/visible"
        case .readOwnedProjects:
            return "projects/owned"
        case .readStarredProjects:
            return "projects/starred"
        case .readAllProjects:
            return "projects/all"
        case .readSingleProject(_, let id):
            return "projects/\(id)"
        case .readProjectEvents(_, let id, _, _):
            return "projects/\(id)/events"
        case .readProjectHooks(_, let id):
            return "projects/\(id)/hooks"
        case .readProjectHook(_, let id, let hookId):
            return "projects/\(id)/hooks/\(hookId)"
        }
    }
}
