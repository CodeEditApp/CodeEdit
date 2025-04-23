//
//  Registry.swift
//  CodeEdit
//
//  Created by Abe Malla on 1/29/25.
//

import Foundation
import ZIPFoundation

@MainActor
final class RegistryManager {
    static let shared: RegistryManager = .init()

    internal let installPath = Settings.shared.baseURL.appending(path: "Language Servers")

    /// The URL of where the registry.json file will be downloaded from
    internal let registryURL = URL(
        string: "https://github.com/mason-org/mason-registry/releases/latest/download/registry.json.zip"
    )!
    /// The URL of where the checksums.txt file will be downloaded from
    internal let checksumURL = URL(
        string: "https://github.com/mason-org/mason-registry/releases/latest/download/checksums.txt"
    )!

    /// Rreference to cached registry data. Will be removed from memory after a certain amount of time.
    private var cachedRegistry: CachedRegistry?
    /// Timer to clear expired cache
    private var cleanupTimer: Timer?
    /// Public access to registry items with cache management
    public var registryItems: [RegistryItem] {
        if let cache = cachedRegistry, !cache.isExpired {
            return cache.items
        }

        // Load the registry items from disk again after cache expires
        if let items = loadItemsFromDisk() {
            cachedRegistry = CachedRegistry(items: items)

            // Set up timer to clear the cache after expiration
            cleanupTimer?.invalidate()
            cleanupTimer = Timer.scheduledTimer(
                withTimeInterval: CachedRegistry.expirationInterval, repeats: false
            ) { [weak self] _ in
                Task { @MainActor in
                    guard let self = self else { return }
                    self.cachedRegistry = nil
                    self.cleanupTimer = nil
                }
            }
            return items
        }

        return []
    }

    @AppSettings(\.languageServers.installedLanguageServers)
    var installedLanguageServers: [String: SettingsData.InstalledLanguageServer]

    deinit {
        cleanupTimer?.invalidate()
    }

    func installPackage(package entry: RegistryItem) async throws {
        return try await Task.detached(priority: .userInitiated) { () in
            let method = await Self.parseRegistryEntry(entry)
            guard let manager = await self.createPackageManager(for: method) else {
                throw PackageManagerError.invalidConfiguration
            }

            // Add to activity viewer
            let activityTitle = "\(entry.name)\("@" + (method.version ?? "latest"))"
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .taskNotification,
                    object: nil,
                    userInfo: [
                        "id": entry.name,
                        "action": "create",
                        "title": "Installing \(activityTitle)"
                    ]
                )
            }

            do {
                try await manager.install(method: method)
            } catch {
                await MainActor.run {
                    Self.updateActivityViewer(entry.name, activityTitle, fail: true)
                }
                // Throw error again so the UI can catch it
                throw error
            }

            // Update settings on the main thread
            await MainActor.run {
                self.installedLanguageServers[entry.name] = .init(
                    packageName: entry.name,
                    isEnabled: true,
                    version: method.version ?? ""
                )
                Self.updateActivityViewer(entry.name, activityTitle, fail: false)
            }
        }.value
    }

    @MainActor
    func removeLanguageServer(packageName: String) async throws {
        let packageName = packageName.removingPercentEncoding ?? packageName
        let packageDirectory = installPath.appending(path: packageName)

        guard FileManager.default.fileExists(atPath: packageDirectory.path) else {
            installedLanguageServers.removeValue(forKey: packageName)
            return
        }

        // Add to activity viewer
        NotificationCenter.default.post(
            name: .taskNotification,
            object: nil,
            userInfo: [
                "id": packageName,
                "action": "create",
                "title": "Removing \(packageName)"
            ]
        )

        do {
            try await Task.detached(priority: .userInitiated) {
                try FileManager.default.removeItem(at: packageDirectory)
            }.value
            installedLanguageServers.removeValue(forKey: packageName)
        } catch {
            throw error
        }
    }

    /// Updates the activity viewer with the status of the language server installation
    @MainActor
    private static func updateActivityViewer(
        _ id: String,
        _ activityName: String,
        fail failed: Bool
    ) {
        if failed {
            NotificationCenter.default.post(
                name: .taskNotification,
                object: nil,
                userInfo: [
                    "id": id,
                    "action": "update",
                    "title": "Could not install \(activityName)",
                    "isLoading": false
                ]
            )
            NotificationCenter.default.post(
                name: .taskNotification,
                object: nil,
                userInfo: [
                    "id": id,
                    "action": "deleteWithDelay",
                    "delay": 5.0,
                ]
            )
        } else {
            NotificationCenter.default.post(
                name: .taskNotification,
                object: nil,
                userInfo: [
                    "id": id,
                    "action": "update",
                    "title": "Successfully installed \(activityName)",
                    "isLoading": false
                ]
            )
            NotificationCenter.default.post(
                name: .taskNotification,
                object: nil,
                userInfo: [
                    "id": id,
                    "action": "deleteWithDelay",
                    "delay": 5.0,
                ]
            )
        }
    }

    /// Create the appropriate package manager for the given installation method
    internal func createPackageManager(for method: InstallationMethod) -> PackageManagerProtocol? {
        switch method.packageManagerType {
        case .npm:
            return NPMPackageManager(installationDirectory: installPath)
        case .cargo:
            return CargoPackageManager(installationDirectory: installPath)
        case .pip:
            return PipPackageManager(installationDirectory: installPath)
        case .golang:
            return GolangPackageManager(installationDirectory: installPath)
        case .github, .sourceBuild:
            return GithubPackageManager(installationDirectory: installPath)
        case .nuget, .opam, .gem, .composer:
            // TODO: IMPLEMENT OTHER PACKAGE MANAGERS
            return nil
        case .none:
            return nil
        }
    }
}

/// `CachedRegistry` is a timer based cache that will remove the registry items from memory
/// after a certain amount of time. This is because this memory is not needed for the majority of the
/// lifetime of the application and can be freed when no longer used.
private final class CachedRegistry {
    let items: [RegistryItem]
    let timestamp: Date

    static let expirationInterval: TimeInterval = 300 // 5 minutes

    init(items: [RegistryItem]) {
        self.items = items
        self.timestamp = Date()
    }

    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > Self.expirationInterval
    }
}

extension Notification.Name {
    static let RegistryUpdatedNotification = Notification.Name("registryUpdatedNotification")
}
