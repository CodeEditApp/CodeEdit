//
//  ExtensionsManager.swift
//  CodeEditModules/ExtensionStore
//
//  Created by Pavel Kasila on 7.04.22.
//

import Foundation
import Light_Swift_Untar
import CodeEditKit
import GRDB

/// Class which handles all extensions (its bundles, instances for each workspace and so on)
final class ExtensionsManager {
    struct PluginWorkspaceKey: Hashable {
        var releaseID: UUID
        var workspace: URL
    }

    /// Shared instance of `ExtensionsManager`
    static let shared: ExtensionsManager? = {
        try? ExtensionsManager()
    }()

    let dbQueue: DatabaseQueue
    let codeeditFolder: URL
    let extensionsFolder: URL

    var loadedBundles: [UUID: Bundle] = [:]
    var loadedPlugins: [PluginWorkspaceKey: ExtensionInterface] = [:]
    var loadedLanguageServers: [PluginWorkspaceKey: LSPClient] = [:]

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
        migrator.registerMigration("v1.0.1") { database in
            try database.alter(table: DownloadedPlugin.databaseTableName) { body in
                body.add(column: "sdk", .text).defaults(to: "swift")
            }
        }
        try migrator.migrate(self.dbQueue)
    }

    /// Removes all plugins which are related to the specified workspace URL
    /// - Parameter url: workspace's URL
    func close(url: URL) {
        loadedPlugins.filter { elem in
            elem.key.workspace == url
        }.forEach { (key: PluginWorkspaceKey, _) in
            loadedPlugins.removeValue(forKey: key)
        }

        loadedLanguageServers.filter { elem in
            elem.key.workspace == url
        }.forEach { (key: PluginWorkspaceKey, client: LSPClient) in
            client.close()
            loadedLanguageServers.removeValue(forKey: key)
        }
    }

    private func loadBundle(id: UUID, withExtension ext: String) throws -> Bundle? {
        guard let bundleURL = try FileManager.default.contentsOfDirectory(
            at: extensionsFolder.appendingPathComponent(id.uuidString,
                                                        isDirectory: true),
            includingPropertiesForKeys: nil,
            options: .skipsPackageDescendants
        ).first(where: { $0.pathExtension == ext }) else { return nil }

        guard let bundle = Bundle(url: bundleURL) else { return nil }

        loadedBundles[id] = bundle

        return bundle
    }

    private func getExtensionBuilder(id: UUID) throws -> ExtensionBuilder.Type? {
        if loadedBundles.keys.contains(id) {
            return loadedBundles[id]?.principalClass as? ExtensionBuilder.Type
        }

        guard let bundle = try loadBundle(id: id, withExtension: "ceext") else {
            return nil
        }

        guard bundle.load() else { return nil }

        return bundle.principalClass as? ExtensionBuilder.Type
    }

    private func getLSPClient(id: UUID, workspaceURL: URL) throws -> LSPClient? {
        if loadedBundles.keys.contains(id) {
            guard let lspFile = loadedBundles[id]?.infoDictionary?["CELSPExecutable"] as? String else {
                return nil
            }

            guard let lspURL = loadedBundles[id]?.url(forResource: lspFile, withExtension: nil) else {
                return nil
            }

            return try LSPClient(lspURL,
                                 workspace: workspaceURL,
                                 arguments: loadedBundles[id]?.infoDictionary?["CELSPArguments"] as? [String])
        }

        guard let bundle = try loadBundle(id: id, withExtension: "celsp") else {
            return nil
        }

        guard let lspFile = bundle.infoDictionary?["CELSPExecutable"] as? String else {
            return nil
        }

        guard let lspURL = bundle.url(forResource: lspFile, withExtension: nil) else {
            return nil
        }

        return try LSPClient(lspURL,
                             workspace: workspaceURL,
                             arguments: loadedBundles[id]?.infoDictionary?["CELSPArguments"] as? [String])
    }

    /// Preloads all extensions' bundles to `loadedBundles`
    func preload() throws {
        let plugins = try self.dbQueue.read { database in
            try DownloadedPlugin.filter(Column("loadable") == true).fetchAll(database)
        }

        try plugins.forEach { plugin in
            switch plugin.sdk {
            case .swift:
                _ = try loadBundle(id: plugin.release, withExtension: "ceext")
            case .languageServer:
                _ = try loadBundle(id: plugin.release, withExtension: "celsp")
            }
        }
    }

    /// Loads extensions' bundles which were not loaded before and passes `ExtensionAPI` as a whole class
    /// or workspace's URL
    /// - Parameter apiBuilder: function which creates `ExtensionAPI` instance based on plugin's ID
    func load(_ apiBuilder: (String) -> ExtensionAPI) throws {
        let plugins = try self.dbQueue.read { database in
            try DownloadedPlugin
                .filter(Column("loadable") == true)
                .fetchAll(database)
        }

        try plugins.forEach { plugin in
            let api = apiBuilder(plugin.plugin.uuidString)
            let key = PluginWorkspaceKey(releaseID: plugin.release, workspace: api.workspaceURL)

            switch plugin.sdk {
            case .swift:
                guard let builder = try getExtensionBuilder(id: plugin.release) else {
                    return
                }

                loadedPlugins[key] = builder.init().build(withAPI: api)
            case .languageServer:
                guard let client = try getLSPClient(id: plugin.release, workspaceURL: api.workspaceURL) else {
                    return
                }
                loadedLanguageServers[key] = client
            }
        }
    }

    /// Installs new extension bundle (plugin) with specified release
    /// - Parameters:
    ///   - plugin: plugin to be installed
    ///   - release: release of the plugin to be installed
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

        // TODO: show progress
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
            try DownloadedPlugin(plugin: plugin.id, release: release.id, loadable: true, sdk: plugin.sdk)
                .insert(database)
        }
    }

    /// Removes extension bundle (plugin)
    /// - Parameter plugin: plugin to be removed
    func remove(plugin: Plugin) throws {
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

        loadedBundles.removeValue(forKey: entry.release)

        loadedPlugins.filter { elem in
            elem.key.releaseID == entry.release
        }.forEach { (key: PluginWorkspaceKey, _) in
            loadedPlugins.removeValue(forKey: key)
        }

        loadedLanguageServers.filter { elem in
            elem.key.releaseID == entry.release
        }.forEach { (key: PluginWorkspaceKey, client: LSPClient) in
            client.close()
            loadedLanguageServers.removeValue(forKey: key)
        }
    }

    /// Checks whether extension's bundle (plugin) is installed
    /// - Parameter plugin: plugin to be checked
    /// - Returns: whether extension's bundle is installed
    func isInstalled(plugin: Plugin) -> Bool {
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
