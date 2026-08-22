//
//  RegistryManagerPersistenceTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

@testable import CELSP
import Testing
import Foundation
import CodeEditCore
import CodeEditSettings
import ShellClient
@testable import CodeEdit

/// Asserts that every `RegistryManager` mutation of `installedLanguageServers` is written back
/// through the settings seam, with the value the user would expect to find after a relaunch.
///
/// These assertions are all about *non-default* state — an empty registry, or one that never
/// reaches the store, fails them. That is the point: a no-op writer must not pass.
@MainActor
@Suite
struct RegistryManagerPersistenceTests {
    private static let packageName = "codeedit-registry-persistence-test-package"

    private func makeStore(installed: [String: LanguageServerSettings.Installed]) -> RecordingSettingsStore {
        var section = LanguageServerSettings()
        section.installedLanguageServers = installed
        return RecordingSettingsStore([LanguageServerSettings.settingsKey: section])
    }

    private func makeManager(store: RecordingSettingsStore) -> RegistryManager {
        RegistryManager(
            eventBus: EventBus(),
            errorNotifier: NoOpErrorNotifier(),
            shellClient: ShellClient(),
            settingsAccessor: store,
            installPath: URL.temporaryDirectory.appending(path: "RegistryManagerPersistenceTests")
        )
    }

    private func installed(_ isEnabled: Bool) -> LanguageServerSettings.Installed {
        .init(packageName: Self.packageName, isEnabled: isEnabled, version: "1.2.3")
    }

    @Test
    func seedingReadsThroughButDoesNotPersist() throws {
        let store = makeStore(installed: [Self.packageName: installed(true)])
        let manager = makeManager(store: store)

        // The seed is read from the store, not invented.
        #expect(manager.installedLanguageServers[Self.packageName]?.version == "1.2.3")
        // Assigning inside `init` does not fire `didSet`, so construction must write nothing.
        #expect(store.writes.isEmpty)
    }

    @Test
    func setPackageEnabledPersists() throws {
        let store = makeStore(installed: [Self.packageName: installed(true)])
        let manager = makeManager(store: store)

        manager.setPackageEnabled(packageName: Self.packageName, enabled: false)

        let written = try #require(store.lastWrite(LanguageServerSettings.self))
        #expect(written.installedLanguageServers[Self.packageName]?.isEnabled == false)
        // And the store now answers with it, i.e. a relaunch would see the change.
        #expect(store.value(LanguageServerSettings.self).installedLanguageServers[Self.packageName]?.isEnabled == false)
    }

    @Test
    func removeLanguageServerPersists() async throws {
        let store = makeStore(installed: [Self.packageName: installed(true)])
        let manager = makeManager(store: store)

        // No directory exists for this name, so the manager takes its "already gone" path and
        // still has to persist the removal.
        #expect(!FileManager.default.fileExists(atPath: manager.installPath.appending(path: Self.packageName).path))

        try await manager.removeLanguageServer(packageName: Self.packageName)

        let written = try #require(store.lastWrite(LanguageServerSettings.self))
        #expect(written.installedLanguageServers[Self.packageName] == nil)
        #expect(store.value(LanguageServerSettings.self).installedLanguageServers.isEmpty)
    }

    @Test
    func successfulInstallPersists() async throws {
        let store = makeStore(installed: [:])
        let manager = makeManager(store: store)

        // A zero-step operation completes immediately without shelling out, which is enough to
        // reach the completion branch that records the installed package.
        let package = RegistryItem(
            name: Self.packageName,
            description: "",
            homepage: "",
            licenses: [],
            languages: [],
            categories: [],
            source: .init(id: "pkg:npm/\(Self.packageName)@4.5.6", asset: nil, build: nil, versionOverrides: nil),
            bin: nil
        )
        let operation = PackageManagerInstallOperation(package: package, steps: [], shellClient: ShellClient())

        try manager.startInstallation(operation: operation)

        // The install runs in a detached-from-us `Task`; wait for the write rather than sleeping a
        // fixed amount.
        var attempts = 0
        while store.lastWrite(LanguageServerSettings.self) == nil && attempts < 200 {
            attempts += 1
            try await Task.sleep(for: .milliseconds(10))
        }

        let written = try #require(
            store.lastWrite(LanguageServerSettings.self),
            "Install completed without persisting the registry"
        )
        #expect(written.installedLanguageServers[Self.packageName]?.version == "4.5.6")
        #expect(written.installedLanguageServers[Self.packageName]?.isEnabled == true)
    }
}
