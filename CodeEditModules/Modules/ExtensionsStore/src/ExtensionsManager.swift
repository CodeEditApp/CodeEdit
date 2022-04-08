//
//  ExtensionsManager.swift
//  
//
//  Created by Pavel Kasila on 7.04.22.
//

import Foundation
import Light_Swift_Untar
import GRDB

@available(macOS 12.0, *)
public class ExtensionsManager {
    public static let shared: ExtensionsManager? = {
        return try? ExtensionsManager()
    }()

    let dbQueue: DatabaseQueue
    let codeeditFolder: URL

    init() throws {
        self.codeeditFolder = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("CodeEdit", isDirectory: true)

        try FileManager.default
            .createDirectory(at: self.codeeditFolder,
                             withIntermediateDirectories: true,
                             attributes: nil)

        self.dbQueue = try DatabaseQueue(path: self.codeeditFolder
                                            .appendingPathComponent("extensions.db")
                                            .absoluteString)

        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1") { database in
            try database.create(table: DownloadedPlugin.databaseTableName) { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("plugin", .text)
                table.column("release", .text)
            }
        }
        try migrator.migrate(self.dbQueue)
    }

    public func install(plugin: Plugin, release: PluginRelease) async throws {
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

        let (source, _) = try await URLSession.shared.download(from: tarball)

        if FileManager.default.fileExists(atPath: cacheTar.path) {
            try FileManager.default.removeItem(at: cacheTar)
        }

        try FileManager.default.moveItem(at: source, to: cacheTar)

        let bundleURL = extensionsFolder.appendingPathComponent(release.id.uuidString, isDirectory: true)

        guard let path = bundleURL.path
                .addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                    throw ExtensionsStoreAPIError.pathError
                }
        try FileManager.default.createFilesAndDirectories(path: path,
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
