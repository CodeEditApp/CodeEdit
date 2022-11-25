//
//  ProjectRouter.swift
//  CodeEditModules/GitAccounts
//
//  Created by Nanashi Li on 2022/03/31.
//

import Foundation

enum Visibility: String {
    case visbilityPublic = "public"
    case visibilityInternal = "interal"
    case visibilityPrivate = "private"
    case all = ""
}

enum OrderBy: String {
    case id = "id"
    case name = "name"
    case path = "path"
    case creationDate = "created_at"
    case updateDate = "updated_at"
    case lastActvityDate = "last_activity_at"
}

enum Sort: String {
    case ascending = "asc"
    case descending = "desc"
}

enum ProjectRouter: Router {
    case readAuthenticatedProjects(
        configuration: RouterConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readVisibleProjects(
        configuration: RouterConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readOwnedProjects(
        configuration: RouterConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readStarredProjects(
        configuration: RouterConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readAllProjects(
        configuration: RouterConfiguration,
        page: String,
        perPage: String,
        archived: Bool,
        visibility: Visibility,
        orderBy: OrderBy,
        sort: Sort,
        search: String,
        simple: Bool)
    case readSingleProject(configuration: RouterConfiguration, id: String)
    case readProjectEvents(configuration: RouterConfiguration, id: String, page: String, perPage: String)
    case readProjectHooks(configuration: RouterConfiguration, id: String)
    case readProjectHook(configuration: RouterConfiguration, id: String, hookId: String)

    var configuration: RouterConfiguration? {
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
        case let .readAuthenticatedProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case let .readVisibleProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case let .readOwnedProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case let .readStarredProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
            return [
                "page": page,
                "per_page": perPage,
                "archived": String(archived),
                "visibility": visibility,
                "order_by": orderBy,
                "sort": sort,
                "search": search,
                "simple": String(simple)]
        case let .readAllProjects(
            _,
            page,
            perPage,
            archived,
            visibility,
            orderBy,
            sort,
            search,
            simple):
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
        case let .readProjectEvents(_, _, page, perPage):
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
        case let .readProjectHook(_, id, hookId):
            return "projects/\(id)/hooks/\(hookId)"
        }
    }
}
