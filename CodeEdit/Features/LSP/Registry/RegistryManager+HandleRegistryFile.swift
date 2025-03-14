//
//  RegistryManager+HandleRegistryFile.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/14/25.
//

import Foundation

extension RegistryManager {
    /// Downloads the latest registry
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

    internal func handleUpdateError(_ error: Error) {
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

    /// Attempts downloading from `url`, with error handling and a retry policy
    internal static func download(from url: URL, attempt: Int = 1) async throws -> Data {
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
    internal func loadItemsFromDisk() -> [RegistryItem]? {
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
}
