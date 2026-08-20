//
//  RegistryManager.swift
//  CodeEdit
//
//  Created by Abe Malla on 1/29/25.
//

import OSLog
import CodeEditSettings
import Foundation
import ZIPFoundation
import Combine
import CodeEditCore

@MainActor
public final class RegistryManager: RegistryManaging {

    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "RegistryManager")
    let installPath: URL

    /// The URL of where the registry.json file will be downloaded from
    let registryURL = URL(
        string: "https://github.com/mason-org/mason-registry/releases/latest/download/registry.json.zip"
    )!
    /// The URL of where the checksums.txt file will be downloaded from
    let checksumURL = URL(
        string: "https://github.com/mason-org/mason-registry/releases/latest/download/checksums.txt"
    )!

    /// Observable presentation state for the Settings extension pages.
    /// The manager owns and feeds it; views observe it instead of the manager.
    public let viewState = RegistryViewState()

    private var installTask: Task<Void, Never>?

    /// Reference to cached registry data. Will be removed from memory after a certain amount of time.
    private var cachedRegistry: CachedRegistry?
    /// Timer to clear expired cache.
    /// nonisolated(unsafe): scheduled and invalidated on the main actor; also
    /// invalidated from `deinit`, which cannot be actor-isolated.
    nonisolated(unsafe) private var cleanupTimer: Timer?

    /// Every mutation persists through the settings seam. Note that the initializer's seeding
    /// assignment happens inside `init` and therefore does *not* fire `didSet` — construction
    /// deliberately writes nothing back.
    public private(set) var installedLanguageServers: [String: LanguageServerSettings.Installed] {
        didSet {
            var settings = settingsAccessor.value(LanguageServerSettings.self)
            settings.installedLanguageServers = installedLanguageServers
            settingsAccessor.setValue(settings)
        }
    }

    private let eventBus: EventBus
    private let errorNotifier: ErrorNotifying
    private let shellClient: ShellClientProtocol
    private let settingsAccessor: SettingsAccessing

    public init(
        eventBus: EventBus,
        errorNotifier: ErrorNotifying,
        shellClient: ShellClientProtocol,
        settingsAccessor: SettingsAccessing,
        installPath: URL
    ) {
        self.installPath = installPath
        self.eventBus = eventBus
        self.errorNotifier = errorNotifier
        self.shellClient = shellClient
        self.settingsAccessor = settingsAccessor
        self.installedLanguageServers = settingsAccessor
            .value(LanguageServerSettings.self)
            .installedLanguageServers
    }

    deinit {
        cleanupTimer?.invalidate()
    }

    private var didStartInitialLoad = false

    /// Loads the registry catalog on first demand (from disk, else network).
    /// Idempotent — safe to call on every appearance of the Extensions page.
    /// The cache-expiry timer set by `setRegistryItems` continues the refresh
    /// cycle after the first load.
    public func loadRegistryIfNeeded() {
        guard !didStartInitialLoad else { return }
        didStartInitialLoad = true
        if let items = loadItemsFromDisk() {
            setRegistryItems(items)
        } else {
            Task {
                await downloadRegistryItems()
            }
        }
    }

    // MARK: - Enable/Disable

    public func setPackageEnabled(packageName: String, enabled: Bool) {
        installedLanguageServers[packageName]?.isEnabled = enabled
    }

    // MARK: - Uninstall

    @MainActor
    public func removeLanguageServer(packageName: String) async throws {
        let packageName = packageName.removingPercentEncoding ?? packageName
        let packageDirectory = installPath.appending(path: packageName)

        guard FileManager.default.fileExists(atPath: packageDirectory.path) else {
            installedLanguageServers.removeValue(forKey: packageName)
            return
        }

        // Add to activity viewer
        eventBus.publish(TaskNotificationEvent(
            .create(TaskNotificationModel(id: packageName, title: "Removing \(packageName)"))
        ))

        do {
            try await Task.detached(priority: .userInitiated) {
                try FileManager.default.removeItem(at: packageDirectory)
            }.value
            installedLanguageServers.removeValue(forKey: packageName)
        } catch {
            throw error
        }
    }

    // MARK: - Install

    public func installOperation(package: RegistryItem) throws -> PackageManagerInstallOperation {
        guard !viewState.isInstalling else {
            throw RegistryManagerError.installationRunning
        }
        guard let method = package.installMethod,
              let manager = method.packageManager(installPath: installPath, shellClient: shellClient) else {
            throw PackageManagerError.invalidConfiguration
        }
        let installSteps = try manager.install(method: method)
        return PackageManagerInstallOperation(package: package, steps: installSteps, shellClient: shellClient)
    }

    /// Starts the actual installation process for a package
    public func startInstallation(operation installOperation: PackageManagerInstallOperation) throws {
        guard !viewState.isInstalling else {
            throw RegistryManagerError.installationRunning
        }

        guard let method = installOperation.package.installMethod else {
            throw PackageManagerError.invalidConfiguration
        }

        // Run it!
        installPackage(operation: installOperation, method: method)
    }

    private func installPackage(operation: PackageManagerInstallOperation, method: InstallationMethod) {
        viewState.isInstalling = true
        installTask = Task { [weak self] in
            defer {
                self?.installTask = nil
                self?.viewState.isInstalling = false
                self?.viewState.runningInstall = nil
            }
            self?.viewState.runningInstall = operation

            // Add to activity viewer
            let activityTitle = "\(operation.package.name)\("@" + (method.version ?? "latest"))"
            self?.eventBus.publish(TaskNotificationEvent(
                .create(TaskNotificationModel(id: operation.package.name, title: "Installing \(activityTitle)"))
            ))

            guard !Task.isCancelled else { return }

            do {
                try await operation.run()
            } catch {
                self?.updateActivityViewer(operation.package.name, activityTitle, fail: true)
                return
            }

            self?.installedLanguageServers[operation.package.name] = .init(
                packageName: operation.package.name,
                isEnabled: true,
                version: method.version ?? ""
            )
            self?.updateActivityViewer(operation.package.name, activityTitle, fail: false)
        }
    }

    // MARK: - Cancel Install

    /// Cancel the currently running installation
    public func cancelInstallation() {
        viewState.runningInstall?.cancel()
        installTask?.cancel()
        installTask = nil
        viewState.isInstalling = false
        viewState.runningInstall = nil
    }

    /// Updates the activity viewer with the status of the language server installation
    @MainActor
    private func updateActivityViewer(
        _ id: String,
        _ activityName: String,
        fail failed: Bool
    ) {
        if failed {
            errorNotifier.postError(
                title: "Could not install \(activityName)",
                description: "There was a problem during installation."
            )
        } else {
            eventBus.publish(TaskNotificationEvent(
                .update(id: id, title: "Successfully installed \(activityName)", isLoading: false)
            ))
            eventBus.publish(TaskNotificationEvent(
                .deleteWithDelay(id: id, delay: 5.0)
            ))
        }
    }

    // MARK: - Cache

    public func setRegistryItems(_ items: [RegistryItem]) {
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
                await self.downloadRegistryItems()
            }
        }

        viewState.registryItems = items
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
