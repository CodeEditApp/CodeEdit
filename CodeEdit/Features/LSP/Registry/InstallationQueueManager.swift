//
//  InstallationQueueManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/13/25.
//

import Foundation

/// A class to manage queued installations of language servers
final class InstallationQueueManager {
    static let shared: InstallationQueueManager = .init()

    /// The maximum number of concurrent installations allowed
    private let maxConcurrentInstallations: Int = 2
    /// Queue of pending installations
    private var installationQueue: [(RegistryItem, (Result<Void, Error>) -> Void)] = []
    /// Currently running installations
    private var runningInstallations: Set<String> = []
    /// Installation status dictionary
    private var installationStatus: [String: PackageInstallationStatus] = [:]

    /// Add a package to the installation queue
    func queueInstallation(package: RegistryItem, completion: @escaping (Result<Void, Error>) -> Void) {
        // If we're already at max capacity and this isn't already running, mark as queued
        if runningInstallations.count >= maxConcurrentInstallations && !runningInstallations.contains(package.name) {
            installationStatus[package.name] = .queued
            installationQueue.append((package, completion))

            // Notify UI that package is queued
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .installationStatusChanged,
                    object: nil,
                    userInfo: ["packageName": package.name, "status": PackageInstallationStatus.queued]
                )
            }
        } else {
            startInstallation(package: package, completion: completion)
        }
    }

    /// Starts the actual installation process for a package
    private func startInstallation(package: RegistryItem, completion: @escaping (Result<Void, Error>) -> Void) {
        installationStatus[package.name] = .installing
        runningInstallations.insert(package.name)

        // Notify UI that installation is now in progress
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .installationStatusChanged,
                object: nil,
                userInfo: ["packageName": package.name, "status": PackageInstallationStatus.installing]
            )
        }

        Task {
            do {
                try await RegistryManager.shared.installPackage(package: package)

                // Notify UI that installation is complete
                installationStatus[package.name] = .installed
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .installationStatusChanged,
                        object: nil,
                        userInfo: ["packageName": package.name, "status": PackageInstallationStatus.installed]
                    )
                    completion(.success(()))
                }
            } catch {
                // Notify UI that installation failed
                installationStatus[package.name] = .failed(error)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .installationStatusChanged,
                        object: nil,
                        userInfo: ["packageName": package.name, "status": PackageInstallationStatus.failed(error)]
                    )
                    completion(.failure(error))
                }
            }

            runningInstallations.remove(package.name)
            processNextInstallations()
        }
    }

    /// Process next installations from the queue if possible
    private func processNextInstallations() {
        while runningInstallations.count < maxConcurrentInstallations && !installationQueue.isEmpty {
            let (package, completion) = installationQueue.removeFirst()
            if runningInstallations.contains(package.name) {
                continue
            }

            startInstallation(package: package, completion: completion)
        }
    }

    /// Cancel an installation if it's in the queue
    func cancelInstallation(packageName: String) {
        installationQueue.removeAll { $0.0.name == packageName }
        installationStatus[packageName] = .cancelled
        runningInstallations.remove(packageName)

        // Notify UI that installation was cancelled
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .installationStatusChanged,
                object: nil,
                userInfo: ["packageName": packageName, "status": PackageInstallationStatus.cancelled]
            )
        }
        processNextInstallations()
    }

    /// Get the current status of an installation
    func getInstallationStatus(packageName: String) -> PackageInstallationStatus {
        return installationStatus[packageName] ?? .notQueued
    }

    /// Cleans up installation status by removing completed or failed installations
    func cleanUpInstallationStatus() {
        let statusKeys = installationStatus.keys.map { $0 }
        for packageName in statusKeys {
            if let status = installationStatus[packageName] {
                switch status {
                case .installed, .failed, .cancelled:
                    installationStatus.removeValue(forKey: packageName)
                case .queued, .installing, .notQueued:
                    break
                }
            }
        }

        // If an item is in runningInstallations but not in an active state in the status dictionary,
        // it might be a stale reference
        let currentRunning = runningInstallations.map { $0 }
        for packageName in currentRunning {
            let status = installationStatus[packageName]
            if status != .installing {
                runningInstallations.remove(packageName)
            }
        }

        // Check for orphaned queue items
        installationQueue = installationQueue.filter { item, _ in
            return installationStatus[item.name] == .queued
        }
    }
}

/// Status of a package installation
enum PackageInstallationStatus: Equatable {
    case notQueued
    case queued
    case installing
    case installed
    case failed(Error)
    case cancelled

    static func == (lhs: PackageInstallationStatus, rhs: PackageInstallationStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notQueued, .notQueued):
            return true
        case (.queued, .queued):
            return true
        case (.installing, .installing):
            return true
        case (.installed, .installed):
            return true
        case (.cancelled, .cancelled):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}

extension Notification.Name {
    static let installationStatusChanged = Notification.Name("installationStatusChanged")
}
