//
//  GitLabAccount.swift
//  CodeEditModules/GitAccounts
//
//  Created by Wesley de Groot on 02/04/2022.
//

import Foundation

extension GitLabAccount {
    /**
     Fetches the Projects for which the authenticated user is a member.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project. Default is false,
     set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func projects(_ session: GitURLSession = URLSession.shared,
                  page: String = "1",
                  perPage: String = "20",
                  archived: Bool = false,
                  visibility: Visibility = Visibility.all,
                  orderBy: OrderBy = OrderBy.creationDate,
                  sort: Sort = Sort.descending,
                  search: String = "",
                  simple: Bool = false,
                  completion: @escaping (_ response: Result<[Project], Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = ProjectRouter.readAuthenticatedProjects(configuration: configuration,
                                                             page: page,
                                                             perPage: perPage,
                                                             archived: archived,
                                                             visibility: visibility,
                                                             orderBy: orderBy,
                                                             sort: sort,
                                                             search: search,
                                                             simple: simple)
        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: Project.self) { json, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let json = json {
                completion(Result.success([json]))
            }
        }
    }

    /**
     Fetches project for a specified ID.
     - parameter id: The ID or namespace/project-name of the project.
     Make sure that the namespace/project-name is URL-encoded, eg. "%2F" for "/".
     - parameter completion: Callback for the outcome of the fetch.
     */
    func project(_ session: GitURLSession = URLSession.shared,
                 id: String,
                 completion: @escaping (_ response: Result<Project, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = ProjectRouter.readSingleProject(configuration: configuration, id: id)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: Project.self) { json, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let json = json {
                completion(Result.success(json))
            }
        }
    }

    /**
     Fetches the Projects which the authenticated user can see.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project. Default is false,
     set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func visibleProjects(_ session: GitURLSession = URLSession.shared,
                         page: String = "1",
                         perPage: String = "20",
                         archived: Bool = false,
                         visibility: Visibility = Visibility.all,
                         orderBy: OrderBy = OrderBy.creationDate,
                         sort: Sort = Sort.descending,
                         search: String = "",
                         simple: Bool = false,
                         completion: @escaping (_ response: Result<Project, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = ProjectRouter.readVisibleProjects(configuration: configuration,
                                                       page: page,
                                                       perPage: perPage,
                                                       archived: archived,
                                                       visibility: visibility,
                                                       orderBy: orderBy,
                                                       sort: sort,
                                                       search: search,
                                                       simple: simple)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: Project.self) { json, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let json = json {
                completion(Result.success(json))
            }
        }
    }

    /**
     Fetches the Projects which are owned by the authenticated user.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project. Default is false,
     set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func ownedProjects(_ session: GitURLSession = URLSession.shared,
                       page: String = "1",
                       perPage: String = "20",
                       archived: Bool = false,
                       visibility: Visibility = Visibility.all,
                       orderBy: OrderBy = OrderBy.creationDate,
                       sort: Sort = Sort.descending,
                       search: String = "",
                       simple: Bool = false,
                       completion: @escaping (_ response: Result<Project, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = ProjectRouter.readOwnedProjects(configuration: configuration,
                                                     page: page,
                                                     perPage: perPage,
                                                     archived: archived,
                                                     visibility: visibility,
                                                     orderBy: orderBy,
                                                     sort: sort,
                                                     search: search,
                                                     simple: simple)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: Project.self) { json, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let json = json {
                completion(Result.success(json))
            }
        }
    }

    /**
     Fetches the Projects which are starred by the authenticated user.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project.
     Default is false, set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func starredProjects(_ session: GitURLSession = URLSession.shared,
                         page: String = "1",
                         perPage: String = "20",
                         archived: Bool = false,
                         visibility: Visibility = Visibility.all,
                         orderBy: OrderBy = OrderBy.creationDate,
                         sort: Sort = Sort.descending,
                         search: String = "",
                         simple: Bool = false,
                         completion: @escaping (_ response: Result<Project, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = ProjectRouter.readStarredProjects(configuration: configuration,
                                                       page: page,
                                                       perPage: perPage,
                                                       archived: archived,
                                                       visibility: visibility,
                                                       orderBy: orderBy,
                                                       sort: sort,
                                                       search: search,
                                                       simple: simple)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: Project.self) { json, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let json = json {
                completion(Result.success(json))
            }
        }
    }

    /**
     Fetches all GitLab projects in the server **(admin only)**.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter archived: Limit by archived status. Default is false, set to `true` to only show archived projects.
     - parameter visibility: Limit by visibility `public`, `internal` or `private`. Default is `""`
     - parameter orderBy: Return projects ordered by `id`, `name`, `path`, `created_at`, `updated_at`,
     or `last_activity_at` fields. Default is `created_at`.
     - parameter sort: Return projects sorted in asc or desc order. Default is `desc`.
     - parameter search: Return list of authorized projects matching the search criteria. Default is `""`
     - parameter simple: Return only the ID, URL, name, and path of each project.
     Default is false, set to `true` to only show simple info.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func allProjects(_ session: GitURLSession = URLSession.shared,
                     page: String = "1",
                     perPage: String = "20",
                     archived: Bool = false,
                     visibility: Visibility = Visibility.all,
                     orderBy: OrderBy = OrderBy.creationDate,
                     sort: Sort = Sort.descending,
                     search: String = "",
                     simple: Bool = false,
                     completion: @escaping (_ response: Result<Project, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = ProjectRouter.readAllProjects(configuration: configuration,
                                                   page: page,
                                                   perPage: perPage,
                                                   archived: archived,
                                                   visibility: visibility,
                                                   orderBy: orderBy,
                                                   sort: sort,
                                                   search: search,
                                                   simple: simple)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: Project.self) { json, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let json = json {
                completion(Result.success(json))
            }
        }
    }

    /**
     Fetches the events for the specified project. Sorted from newest to oldest.
     - parameter page: Current page for project pagination. `1` by default.
     - parameter perPage: Number of projects per page. `100` by default.
     - parameter id: The ID or NAMESPACE/PROJECT_NAME of the project.
     - parameter completion: Callback for the outcome of the fetch.
     */
    func projectEvents(_ session: GitURLSession = URLSession.shared,
                       id: String,
                       page: String = "1",
                       perPage: String = "20",
                       completion: @escaping (_ response: Result<Event, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        let router = ProjectRouter.readProjectEvents(configuration: configuration,
                                                     id: id,
                                                     page: page,
                                                     perPage: perPage)

        return router.load(session,
                           dateDecodingStrategy: .formatted(Time.rfc3339DateFormatter),
                           expectedResultType: Event.self) { json, error in

            if let error = error {
                completion(Result.failure(error))
            }

            if let json = json {
                completion(Result.success(json))
            }
        }
    }
}
