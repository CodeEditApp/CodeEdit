//
//  InstallationQueueManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 3/13/25.
//

import Foundation

/// A class to manage queued installations of language servers
class InstallationQueueManager {
    static let shared: InstallationQueueManager = .init()

    /// The maximum number of concurrent installations allowed
    private let maxConcurrentInstallations: Int = 2
    /// Queue of pending installations
    private var installationQueue: [(RegistryItem, (Result<Void, Error>) -> Void)] = []
    /// Currently running installations
    private var runningInstallations: Int = 0
    /// Installation status dictionary
    private var installationStatus: [String: PackageInstallationStatus] = [:]

    private init() {}

    /// Add a package to the installation queue
    func queueInstallation(package: RegistryItem, completion: @escaping (Result<Void, Error>) -> Void) {
        installationStatus[package.name] = .queued
        installationQueue.append((package, completion))
        processNextInstallations()

        // Notify UI that package is queued
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .installationStatusChanged,
                object: nil,
                userInfo: ["packageName": package.name, "status": PackageInstallationStatus.queued]
            )
        }
    }

    /// Process next installations from the queue if possible
    private func processNextInstallations() {
        while runningInstallations < maxConcurrentInstallations && !installationQueue.isEmpty {
            let (package, completion) = installationQueue.removeFirst()
            runningInstallations += 1
            installationStatus[package.name] = .installing

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

                runningInstallations -= 1
                processNextInstallations()
            }
        }
    }

    /// Cancel an installation if it's in the queue
    func cancelInstallation(packageName: String) {
        installationQueue.removeAll { $0.0.name == packageName }
        installationStatus[packageName] = .cancelled

        // Notify UI that installation was cancelled
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .installationStatusChanged,
                object: nil,
                userInfo: ["packageName": packageName, "status": PackageInstallationStatus.cancelled]
            )
        }
    }

    /// Get the current status of an installation
    func getInstallationStatus(packageName: String) -> PackageInstallationStatus {
        return installationStatus[packageName] ?? .notQueued
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
