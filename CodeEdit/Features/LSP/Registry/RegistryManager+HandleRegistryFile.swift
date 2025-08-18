//
//  RegistryManager+HandleRegistryFile.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/14/25.
//

import Foundation

extension RegistryManager {
    /// Downloads the latest registry
    func downloadRegistryItems() async {
        isDownloadingRegistry = true
        defer { isDownloadingRegistry = false }

        let registryData, checksumData: Data
        do {
            async let zipDataTask = download(from: self.registryURL)
            async let checksumsTask = download(from: self.checksumURL)

            (registryData, checksumData) = try await (zipDataTask, checksumsTask)
        } catch {
            handleUpdateError(error)
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
            downloadError = nil
        } catch {
            handleUpdateError(RegistryManagerError.writeFailed(error: error))
            return
        }

        do {
            if let items = loadItemsFromDisk() {
                setRegistryItems(items)
            } else {
                throw RegistryManagerError.failedToSaveRegistryCache
            }
        } catch {
            handleUpdateError(error)
        }
    }

    func handleUpdateError(_ error: Error) {
        self.downloadError = error
        if let regError = error as? RegistryManagerError {
            switch regError {
            case .installationRunning:
                return // Shouldn't need to handle
            case .invalidResponse(let statusCode):
                logger.error("Invalid response received: \(statusCode)")
            case let .downloadFailed(url, error):
                logger.error("Download failed for \(url.absoluteString): \(error.localizedDescription)")
            case let .maxRetriesExceeded(url, error):
                logger.error("Max retries exceeded for \(url.absoluteString): \(error.localizedDescription)")
            case let .writeFailed(error):
                logger.error("Failed to write files to disk: \(error.localizedDescription)")
            case .failedToSaveRegistryCache:
                logger.error("Failed to read registry from cache after download and write.")
            }
        } else {
            logger.error("Unexpected registry error: \(error.localizedDescription)")
        }
    }

    /// Attempts downloading from `url`, with error handling and a retry policy
    @Sendable
    func download(from url: URL, attempt: Int = 1) async throws -> Data {
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
    func loadItemsFromDisk() -> [RegistryItem]? {
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
            return nil
        }

        do {
            let registryData = try Data(contentsOf: registryPath)
            let items = try JSONDecoder().decode([RegistryItem].self, from: registryData)
            return items.filter { $0.categories.contains("LSP") }
        } catch {
            return nil
        }
    }
}
