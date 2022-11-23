//
//  ExtensionsStoreAPI.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation
import Combine

enum ExtensionsStoreAPIError: Error {
    case noTarball
    case urlFailure
    case pathError
}

// TODO: add authorization

/// Structure to work with Extensions Store API
enum ExtensionsStoreAPI {

    static let base = URL(string: "https://codeedit.pkasila.net/api/")!
    static let agent = Agent()

    /// Lists plugins on the specified page
    /// - Parameter page: page to be requested
    /// - Returns: publisher with the page
    static func plugins(page: Int) -> AnyPublisher<Page<Plugin>, Error> {
        var components = URLComponents(url: base.appendingPathComponent("plugins"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            .init(name: "page", value: "\(page)")
        ]

        guard let url = components?.url else {
            return .init(Fail(error: ExtensionsStoreAPIError.urlFailure as Error))
        }

        let request = URLRequest(url: url)
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    /// Plugin by ID
    /// - Parameter id: identifier of the plugin
    /// - Returns: publisher with `Plugin`
    static func plugin(id: UUID) -> AnyPublisher<Plugin, Error> {
        let request = URLRequest(url: base.appendingPathComponent("plugins/\(id.uuidString)"))
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    /// Lists plugin's releases on the specified page
    /// - Parameters:
    ///   - id: plugin's ID
    ///   - page: page to be requested
    /// - Returns: publisher with the page
    static func pluginReleases(id: UUID, page: Int) -> AnyPublisher<Page<PluginRelease>, Error> {
        var components = URLComponents(url: base.appendingPathComponent("plugins/\(id.uuidString)/releases"),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = [
            .init(name: "page", value: "\(page)")
        ]

        guard let url = components?.url else {
            return .init(Fail(error: ExtensionsStoreAPIError.urlFailure as Error))
        }

        let request = URLRequest(url: url)
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    /// Release by ID
    /// - Parameter id: release's ID
    /// - Returns: publisher with `PluginRelease`
    static func release(id: UUID) -> AnyPublisher<PluginRelease, Error> {
        let request = URLRequest(url: base.appendingPathComponent("releases/\(id.uuidString)"))
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}

final class Agent {
    func run<T: Decodable>(_ request: URLRequest,
                           _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
