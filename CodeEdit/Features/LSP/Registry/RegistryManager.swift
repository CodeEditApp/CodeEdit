//
//  Registry.swift
//  CodeEdit
//
//  Created by Abe Malla on 1/29/25.
//

import Combine
import Foundation
import ZIPFoundation

private let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
private let installPath = homeDirectory
    .appending(path: "Library")
    .appending(path: "Application Support")
    .appending(path: "CodeEdit")
    .appending(path: "language-servers")

@MainActor
final class RegistryManager {
    static let shared: RegistryManager = .init()

    /// The URL of where the registry.json file will be downloaded from
    private let registryURL = URL(
        string: "https://github.com/mason-org/mason-registry/releases/latest/download/registry.json.zip"
    )!
    /// The URL of where the checksums.txt file will be downloaded from
    private let checksumURL = URL(
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

    /// Downloads the latest registry and saves to "~/Library/Application Support/CodeEdit/extensions"
    func update() async {
        // swiftlint:disable:next large_tuple
        let result = await Task.detached(priority: .userInitiated) { () -> (
            registryData: Data?, checksumData: Data?, error: Error?
        ) in
            do {
                async let zipDataTask = Self.download(from: self.registryURL)
                async let checksumsTask = Self.download(from: self.checksumURL)

                let (registryData, checksumData) = try await (zipDataTask, checksumsTask)
                return (registryData, checksumData, nil)
            } catch {
                return (nil, nil, error)
            }
        }.value

        if let error = result.error {
            handleUpdateError(error)
            return
        }

        guard let registryData = result.registryData, let checksumData = result.checksumData else {
            return
        }

        do {
            // Make sure the extensions folder exists first
            try FileManager.default.createDirectory(at: installPath, withIntermediateDirectories: true)

            let tempZipURL = installPath.appending(path: "temp.zip")
            let checksumDestination = installPath.appending(path: "checksums.txt")

            // Delete existing zip data if it exists
            if FileManager.default.fileExists(atPath: tempZipURL.path) {
                try FileManager.default.removeItem(at: tempZipURL)
            }
            let registryJsonPath = installPath.appending(path: "registry.json").path
            if FileManager.default.fileExists(atPath: registryJsonPath) {
                try FileManager.default.removeItem(atPath: registryJsonPath)
            }

            // Write the zip data to a temporary file, then unzip
            try registryData.write(to: tempZipURL)
            try FileManager.default.unzipItem(at: tempZipURL, to: installPath)
            try FileManager.default.removeItem(at: tempZipURL)

            try checksumData.write(to: checksumDestination)

            NotificationCenter.default.post(name: .RegistryUpdatedNotification, object: nil)
        } catch {
            print("Error details: \(error)")
            handleUpdateError(RegistryManagerError.writeFailed(error: error))
        }
    }

    private func handleUpdateError(_ error: Error) {
        if let regError = error as? RegistryManagerError {
            switch regError {
            case .invalidResponse(let statusCode):
                print("Invalid response received: \(statusCode)")
            case let .downloadFailed(url, error):
                print("Download failed for \(url.absoluteString): \(error.localizedDescription)")
            case let .maxRetriesExceeded(url, error):
                print("Max retries exceeded for \(url.absoluteString): \(error.localizedDescription)")
            case let .writeFailed(error):
                print("Failed to write files to disk: \(error.localizedDescription)")
            }
        } else {
            print("Unexpected registry error: \(error.localizedDescription)")
        }
    }

    func installPackage(package entry: RegistryItem) async throws {
        return try await Task.detached(priority: .userInitiated) { () in
            let method = await Self.parseRegistryEntry(entry)
            guard let manager = await Self.createPackageManager(for: method, installPath) else {
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

    /// Attempts downloading from `url`, with error handling and a retry policy
    private static func download(from url: URL, attempt: Int = 1) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw RegistryManagerError.downloadFailed(
                    url: url, error: NSError(domain: "Invalid response type", code: -1)
                )
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw RegistryManagerError.invalidResponse(statusCode: httpResponse.statusCode)
            }

            return data
        } catch {
            if attempt <= 3 {
                let delay = pow(2.0, Double(attempt))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await download(from: url, attempt: attempt + 1)
            } else {
                throw RegistryManagerError.maxRetriesExceeded(url: url, lastError: error)
            }
        }
    }

    /// Loads registry items from disk
    private func loadItemsFromDisk() -> [RegistryItem]? {
        let registryPath = installPath.appending(path: "registry.json")
        let fileManager = FileManager.default

        // Update the file every 24 hours
        let needsUpdate = !fileManager.fileExists(atPath: registryPath.path) || {
            guard let attributes = try? fileManager.attributesOfItem(atPath: registryPath.path),
                  let modificationDate = attributes[.modificationDate] as? Date else {
                return true
            }
            let hoursSinceLastUpdate = Date().timeIntervalSince(modificationDate) / 3600
            return hoursSinceLastUpdate >= 24
        }()

        if needsUpdate {
            Task { await update() }
            return nil
        }

        do {
            let registryData = try Data(contentsOf: registryPath)
            let items = try JSONDecoder().decode([RegistryItem].self, from: registryData)
            return items.filter { $0.categories.contains("LSP") }
        } catch {
            Task { await update() }
            return nil
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
