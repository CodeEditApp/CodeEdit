//
//  Registry.swift
//  CodeEdit
//
//  Created by Abe Malla on 1/29/25.
//

import Combine
import Foundation
import ZIPFoundation

final class RegistryManager {
    static let shared: RegistryManager = .init()

    private let saveLocation = Settings.shared.baseURL.appending(path: "extensions")
    private let registryURL = URL(
        string: "https://github.com/mason-org/mason-registry/releases/latest/download/registry.json.zip"
    )!
    private let checksumURL = URL(
        string: "https://github.com/mason-org/mason-registry/releases/latest/download/checksums.txt"
    )!
    private var cancellables: Set<AnyCancellable> = []

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
                self?.cachedRegistry = nil
                self?.cleanupTimer = nil
            }
            return items
        }

        return []
    }

    deinit {
        cleanupTimer?.invalidate()
    }

    /// Downloads the latest registry and saves to "~/Library/Application Support/CodeEdit/extensions"
    func update() async {
        async let zipDataTask = download(from: registryURL)
        async let checksumsTask = download(from: checksumURL)

        do {
            // Make sure the extensions folder exists first
            try FileManager.default.createDirectory(at: saveLocation, withIntermediateDirectories: true)

            let (registryData, checksumData) = try await (zipDataTask, checksumsTask)

            let tempZipURL = saveLocation.appending(path: "temp.zip")
            let checksumDestination = saveLocation.appending(path: "checksums.txt")

            do {
                // Delete existing zip data if it exists
                if FileManager.default.fileExists(atPath: tempZipURL.path) {
                    try FileManager.default.removeItem(at: tempZipURL)
                }
                let registryJsonPath = saveLocation.appending(path: "registry.json").path
                if FileManager.default.fileExists(atPath: registryJsonPath) {
                    try FileManager.default.removeItem(atPath: registryJsonPath)
                }

                // Write the zip data to a temporary file, then unzip
                try registryData.write(to: tempZipURL)
                try FileManager.default.unzipItem(at: tempZipURL, to: saveLocation)
                try FileManager.default.removeItem(at: tempZipURL)

                try checksumData.write(to: checksumDestination)

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .RegistryUpdatedNotification, object: nil)
                }
            } catch {
                print("Error details: \(error)")
                throw RegistryManagerError.writeFailed(error: error)
            }
        } catch let error as RegistryManagerError {
            switch error {
            case .invalidResponse(let statusCode):
                print("Invalid response received: \(statusCode)")
            case let .downloadFailed(url, error):
                print("Download failed for \(url.absoluteString): \(error.localizedDescription)")
            case let .maxRetriesExceeded(url, error):
                print("Max retries exceeded for \(url.absoluteString): \(error.localizedDescription)")
            case let .writeFailed(error):
                print("Failed to write files to disk: \(error.localizedDescription)")
            }
        } catch {
            print("Unexpected registry error: \(error.localizedDescription)")
        }
    }

    /// Attempts downloading from `url`, with error handling and a retry policy
    private func download(from url: URL, attempt: Int = 1) async throws -> Data {
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
        let registryPath = saveLocation.appending(path: "registry.json")
        let fileManager = FileManager.default

        // Update the file every 24 hours
        let needsUpdate = !fileManager.fileExists(atPath: registryPath.path) || {
            guard let attributes = try? fileManager.attributesOfItem(atPath: registryPath.path),
                  let modificationDate = attributes[.modificationDate] as? Date else {
                return true
            }
            let hoursSinceLastUpdate = Date().timeIntervalSince(modificationDate) / 3600
            return hoursSinceLastUpdate > 24
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
