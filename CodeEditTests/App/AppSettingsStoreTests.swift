//
//  AppSettingsStoreTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import CELSP
import CESourceControl
import CETerminal
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

    /// An unparseable `settings.json` must be copied aside **before** the empty store it falls back
    /// to can be written over it.
    ///
    /// The fallback itself is not the bug — the app has to launch. Losing the original is, and it is
    /// silent: the user sees settings reset to defaults and has nothing left to recover from.
    @Test
    func anUnreadableFileIsPreservedBeforeTheFirstWrite() async throws {
        let corruptContents = #"{"general": {"fileIconStyle": "colo"#  // truncated mid-write
        let (store, url) = try makeStore(seed: corruptContents)

        // Loading fell back to defaults, as it must to keep launching.
        #expect(store.value(GeneralSettings.self) == GeneralSettings())

        // The copy must exist *before* any write, not be made on the way out.
        let backups = try backupFiles(besides: url)
        #expect(backups.count == 1, "the unreadable file was not copied aside")
        #expect(try String(contentsOf: try #require(backups.first), encoding: .utf8) == corruptContents)

        // And the original is still where the app expects it, so the copy is a copy, not a move.
        #expect(FileManager.default.fileExists(atPath: url.path))

        // Now let a write land and confirm the preserved copy is untouched by it.
        var section = store.value(GeneralSettings.self)
        section.fileIconStyle = .monochrome
        store.setValue(section)
        await settle { (try? Data(contentsOf: url))?.count != corruptContents.utf8.count }

        let after = try backupFiles(besides: url)
        #expect(after.count == 1)
        #expect(try String(contentsOf: try #require(after.first), encoding: .utf8) == corruptContents)
    }

    /// A file that loads but holds **one** undecodable section must be copied aside before the write
    /// that replaces that section, and the copy must still hold the user's original text.
    ///
    /// The scenario is a hand-edit: `"theme": []` is valid JSON but not a `ThemeSettings`, so the
    /// section reads as defaults and the next theme change persists those defaults over it. The
    /// assertion is deliberately on the *original bytes surviving somewhere*, not on the values read
    /// back — asserting defaults would pass against the unprotected implementation too.
    @Test
    func anUndecodableSectionIsPreservedBeforeTheWriteThatReplacesIt() throws {
        let seed = #"{"theme":[],"general":{"fileIconStyle":"monochrome"}}"#
        let (store, url) = try makeStore(seed: seed)

        // The rest of the file is fine, so nothing is copied on load.
        #expect(store.value(GeneralSettings.self).fileIconStyle == .monochrome)
        #expect(try backupFiles(besides: url).isEmpty, "a readable file must not be copied on load")

        // Reading the broken section falls back to defaults, but changes nothing on disk.
        #expect(store.value(ThemeSettings.self) == ThemeSettings())
        #expect(try backupFiles(besides: url).isEmpty, "a read is not destructive and needs no copy")

        // The write is the destructive moment; the copy must already exist when it lands.
        var theme = store.value(ThemeSettings.self)
        theme.matchAppearance = !theme.matchAppearance
        store.setValue(theme)

        let backups = try backupFiles(besides: url)
        #expect(backups.count == 1, "the undecodable section was replaced with no copy of the original")
        #expect(try String(contentsOf: try #require(backups.first), encoding: .utf8) == seed)
    }

    /// A second write of the same broken section must not pile up copies — one per store is enough,
    /// because the copy is of the whole file.
    @Test
    func onlyOneCopyIsMadeHoweverManySectionsAreReplaced() throws {
        let (store, url) = try makeStore(seed: #"{"theme":[],"terminal":"nope"}"#)

        var theme = store.value(ThemeSettings.self)
        theme.matchAppearance = !theme.matchAppearance
        store.setValue(theme)

        var terminal = store.value(TerminalSettings.self)
        terminal.cursorBlink = !terminal.cursorBlink
        store.setValue(terminal)

        #expect(try backupFiles(besides: url).count == 1)
    }

    /// A *missing* file is the first-launch case: an empty store is correct and nothing is copied.
    @Test
    func anAbsentFileIsNotTreatedAsCorruption() throws {
        let (store, url) = try makeStore()

        #expect(store.value(GeneralSettings.self) == GeneralSettings())
        #expect(try backupFiles(besides: url).isEmpty, "a first launch must not leave a corrupt-copy")
    }

    private func backupFiles(besides url: URL) throws -> [URL] {
        try FileManager.default
            .contentsOfDirectory(at: url.deletingLastPathComponent(), includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.contains(".corrupt-") }
    }

    private func settle(until: () -> Bool) async {
        var attempts = 0
        while !until() && attempts < 120 {
            attempts += 1
            try? await Task.sleep(for: .milliseconds(50))
        }
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
