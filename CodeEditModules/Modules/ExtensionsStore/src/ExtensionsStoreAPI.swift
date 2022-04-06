//
//  ExtensionsStoreAPI.swift
//  
//
//  Created by Pavel Kasila on 5.04.22.
//

import Foundation
import Combine
import Light_Swift_Untar
import GRDB

public enum ExtensionsStoreAPIError: Error {
    case noTarball
}

// TODO: add authorization

public class ExtensionsStoreAPI {
    public init() throws {
        self.codeeditFolder = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("CodeEdit", isDirectory: true)
        self.dbQueue = try DatabaseQueue(path: self.codeeditFolder
                                            .appendingPathComponent("extensions.db")
                                            .absoluteString)

        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1") { database in
            try database.create(table: "downloadedplugin") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("plugin", .text)
                table.column("release", .text)
            }
        }
    }

    let base = URL(string: "https://codeedit.pkasila.net/api/")!
    let agent = Agent()
    let dbQueue: DatabaseQueue
    let codeeditFolder: URL

    func plugins(page: Int) -> AnyPublisher<Page<Plugin>, Error> {
        let request = URLRequest(url: base.appendingPathComponent("plugins"))
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    func plugin(id: UUID) -> AnyPublisher<Plugin, Error> {
        let request = URLRequest(url: base.appendingPathComponent("plugins/\(id.uuidString)"))
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    func pluginReleases(id: UUID) -> AnyPublisher<Page<PluginRelease>, Error> {
        let request = URLRequest(url: base.appendingPathComponent("plugins/\(id.uuidString)/releases"))
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    func release(id: UUID) -> AnyPublisher<PluginRelease, Error> {
        let request = URLRequest(url: base.appendingPathComponent("releases/\(id.uuidString)"))
        return agent.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }

    @available(macOS 12.0, *)
    func install(plugin: Plugin, release: PluginRelease) async throws {
        guard let tarball = release.tarball else {
            throw ExtensionsStoreAPIError.noTarball
        }

        let extensionsFolder = codeeditFolder.appendingPathComponent("Extensions", isDirectory: true)

        try FileManager.default
            .createDirectory(at: extensionsFolder,
                             withIntermediateDirectories: true,
                             attributes: nil)

        let cacheTar = try FileManager.default
            .url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("\(release.id.uuidString).tar")

        try await agent.download(url: tarball, to: cacheTar)

        let bundleURL = extensionsFolder.appendingPathComponent(release.id.uuidString, isDirectory: true)

        try FileManager.default.createFilesAndDirectories(path: bundleURL.path,
                                                          tarPath: cacheTar.path)

        let manifest = extensionsFolder.appendingPathComponent("\(plugin.id.uuidString).json")

        try JSONEncoder().encode(plugin).write(to: manifest)

        // save to db

        try await dbQueue.write { database in
            try DownloadedPlugin(plugin: plugin.id, release: release.id)
                .insert(database)
        }
    }
}

class Agent {
    func run<T: Decodable>(_ request: URLRequest,
                           _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
                let value = try decoder.decode(T.self, from: result.data)
                return Response(value: value, response: result.response)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    @available(macOS 12.0, *)
    func download(url: URL, to localUrl: URL) async throws {
        let (source, _) = try await URLSession.shared.download(from: url)
        try FileManager.default.moveItem(at: source, to: localUrl)
    }
}
