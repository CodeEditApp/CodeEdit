//
//  AppSettingsStoreTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import Foundation
import Testing
import CodeEditSettings
@testable import CodeEdit

/// Verifies `AppSettingsStore` reads and writes real, persisted settings rather than answering with
/// section defaults like `DefaultSettingsReader` would. A test that only checked defaults would pass
/// against either implementation and prove nothing.
///
/// Each test builds its own store over a temporary file. The predecessor of this suite mutated the
/// `Settings.shared` singleton and had to restore what it found, serialize against every other suite
/// that touched settings, and could never assert anything about the file on disk. That is the
/// concrete payoff of moving ownership into the composition root.
@MainActor
struct AppSettingsStoreTests {

    /// A store over a fresh temporary `settings.json` that no other test can see.
    private func makeStore(seed: String? = nil) throws -> (AppSettingsStore, URL) {
        let directory = URL.temporaryDirectory.appending(path: "AppSettingsStoreTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appending(path: "settings.json")
        if let seed {
            try Data(seed.utf8).write(to: url)
        }
        return (AppSettingsStore(settingsURL: url), url)
    }

    @Test
    func readsAValueSeededOnDisk() throws {
        // Non-default: `SourceControlGeneral.sourceControlIsEnabled` defaults to `true`, so
        // `DefaultSettingsReader` (or a store that never read the file) could not produce `false`.
        let (store, _) = try makeStore(seed: #"{"sourceControl":{"general":{"sourceControlIsEnabled":false}}}"#)

        #expect(store.value(SourceControlSettings.self).general.sourceControlIsEnabled == false)
    }

    @Test
    func writtenSectionReadsBack() throws {
        let (store, _) = try makeStore()

        var section = store.value(SourceControlSettings.self)
        #expect(section.general.sourceControlIsEnabled == true, "starts at its default")
        section.general.sourceControlIsEnabled = false
        store.setValue(section)

        #expect(store.value(SourceControlSettings.self).general.sourceControlIsEnabled == false)
    }

    @Test
    func aWriteBumpsTheRevision() throws {
        let (store, _) = try makeStore()
        let before = store.revision

        var section = store.value(TerminalSettings.self)
        section.cursorBlink = !section.cursorBlink
        store.setValue(section)

        #expect(store.revision == before + 1)
    }

    /// The relaunch guarantee: a write must reach disk on its own, without anyone calling `save`.
    ///
    /// This is what the `throttle(for: 2, scheduler: RunLoop.main)` pipeline exists for, so the poll
    /// window is deliberately several times the interval rather than a fixed sleep of exactly it.
    @Test
    func aWriteReachesDiskThroughTheThrottle() async throws {
        let (store, url) = try makeStore()

        var section = store.value(LanguageServerSettings.self)
        section.installedLanguageServers = [
            "round-trip-test": .init(packageName: "round-trip-test", isEnabled: false, version: "9.9.9")
        ]
        store.setValue(section)

        var attempts = 0
        while !FileManager.default.fileExists(atPath: url.path) && attempts < 120 {
            attempts += 1
            try? await Task.sleep(for: .milliseconds(50))
        }

        let reloaded = AppSettingsStore(settingsURL: url)
        let readBack = reloaded.value(LanguageServerSettings.self).installedLanguageServers["round-trip-test"]
        #expect(readBack?.version == "9.9.9", "a settings write did not survive to disk")
        #expect(readBack?.isEnabled == false)
    }

    /// A section this build has no field for must survive a save, or a disabled extension loses its
    /// configuration the first time anything else is written.
    @Test
    func unknownSectionsSurviveAWrite() async throws {
        let (store, url) = try makeStore(seed: #"{"someFutureFeature":{"keep":"me"}}"#)

        var section = store.value(GeneralSettings.self)
        section.fileIconStyle = .monochrome
        store.setValue(section)

        var attempts = 0
        while attempts < 120 {
            attempts += 1
            try? await Task.sleep(for: .milliseconds(50))
            if let data = try? Data(contentsOf: url),
               let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               object["general"] != nil {
                break
            }
        }

        let data = try Data(contentsOf: url)
        let object = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect((object["someFutureFeature"] as? [String: String])?["keep"] == "me")
    }
}
