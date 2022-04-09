//
//  ExtensionsManager.swift
//  
//
//  Created by Pavel Kasila on 7.04.22.
//

import Foundation
import Light_Swift_Untar
import CEExtensionKit
import GRDB

@available(macOS 12.0, *)
public class ExtensionsManager {
    struct PluginWorkspaceKey: Hashable {
        var releaseID: UUID
        var workspace: URL
    }

    public static let shared: ExtensionsManager? = {
        return try? ExtensionsManager()
    }()

    let dbQueue: DatabaseQueue
    let codeeditFolder: URL
    let extensionsFolder: URL

    var loadedBundles: [UUID: Bundle] = [:]
    var loadedPlugins: [PluginWorkspaceKey: ExtensionInterface] = [:]

    init() throws {
        self.codeeditFolder = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("CodeEdit", isDirectory: true)
        self.extensionsFolder = codeeditFolder.appendingPathComponent("Extensions", isDirectory: true)

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
                table.column("loadable", .boolean)
            }
        }
        try migrator.migrate(self.dbQueue)
    }

    public func close(url: URL) {
        loadedPlugins.filter { elem in
            return elem.key.workspace == url
        }.forEach { (key: PluginWorkspaceKey, _) in
            loadedPlugins.removeValue(forKey: key)
        }
    }

    private func getExtensionBuilder(id: UUID) throws -> ExtensionBuilder.Type? {
        if loadedBundles.keys.contains(id) {
            return loadedBundles[id]?.principalClass as? ExtensionBuilder.Type
        }

        guard let bundleURL = try FileManager.default.contentsOfDirectory(
            at: extensionsFolder.appendingPathComponent(id.uuidString,
                                                        isDirectory: true),
            includingPropertiesForKeys: nil,
            options: .skipsPackageDescendants
        ).first else { return nil }

        guard bundleURL.pathExtension == "ceext" else { return nil }
        guard let bundle = Bundle(url: bundleURL) else { return nil }

        guard bundle.load() else { return nil }

        loadedBundles[id] = bundle

        return bundle.principalClass as? ExtensionBuilder.Type
    }

    public func load(_ apiInitializer: (String) -> ExtensionAPI) throws {
        let plugins = try self.dbQueue.read { database in
            try DownloadedPlugin.filter(Column("loadable") == true).fetchAll(database)
        }

        try plugins.forEach { plugin in
            guard let builder = try getExtensionBuilder(id: plugin.release) else {
                return
            }

            let api = apiInitializer(plugin.plugin.uuidString)

            let key = PluginWorkspaceKey(releaseID: plugin.release, workspace: api.workspaceURL)
            loadedPlugins[key] = builder.init().build(withAPI: api)
        }
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
            try DownloadedPlugin(plugin: plugin.id, release: release.id, loadable: true)
                .insert(database)
        }
    }

    public func remove(plugin: Plugin) throws {
        guard let entry = (try self.dbQueue.read { database in
            try DownloadedPlugin.filter(Column("plugin") == plugin.id).fetchOne(database)
        }) else {
            return
        }

        let manifestURL = extensionsFolder.appendingPathComponent("\(entry.plugin.uuidString).json")
        if FileManager.default.fileExists(atPath: manifestURL.path) {
            try FileManager.default.removeItem(at: manifestURL)
        }

        let bundleURL = extensionsFolder.appendingPathComponent("\(entry.release.uuidString)", isDirectory: true)
        if FileManager.default.fileExists(atPath: bundleURL.path) {
            try FileManager.default.removeItem(at: bundleURL)
        }

        _ = try self.dbQueue.write { database in
            try entry.delete(database)
        }
    }

    public func isInstalled(plugin: Plugin) -> Bool {
        do {
            let entry = try self.dbQueue.read { database in
                try DownloadedPlugin.filter(Column("plugin") == plugin.id).fetchOne(database)
            }
            return entry != nil
        } catch {
            return false
        }
    }
}
