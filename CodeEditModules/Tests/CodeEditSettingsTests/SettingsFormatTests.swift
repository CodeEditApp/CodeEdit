//
//  SettingsFormatTests.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

import Testing
import Foundation
import CELSP
import CESourceControl
import CETerminal
@testable import CodeEditSettings

struct SettingsFormatTests {

    private func fixture(_ name: String) throws -> Data {
        let url = try #require(
            Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures")
        )
        return try Data(contentsOf: url)
    }

    private func parsed(_ data: Data) throws -> NSDictionary {
        try #require(JSONSerialization.jsonObject(with: data) as? NSDictionary)
    }

    /// Decoding then encoding a fully-populated settings file must not change any key or value.
    ///
    /// The fixture deliberately holds no default values: a fixture of defaults would pass even if
    /// decoding silently fell back to defaults, which is the failure this guards against.
    ///
    /// It used to round-trip a `SettingsData`, which is no longer possible: that aggregate is an
    /// app-side façade over this store and is not `Codable`. Every section is instead read *and
    /// written back* through the store, which is the same work: reading alone would prove nothing,
    /// because an unread section is re-emitted as the raw JSON it came in as. Writing the decoded
    /// value back replaces the stored JSON with whatever the Swift type produces — exactly the step
    /// that could silently drop or rename a key.
    @Test
    func fullSettingsRoundTripsUnchanged() throws {
        let original = try fixture("full-settings")
        let store = try SettingsStore(data: original)

        func reencode<S: SettingsSection>(_ type: S.Type) {
            let decoded = store[S.self]
            store[S.self] = decoded
        }

        reencode(GeneralSettings.self)
        reencode(AccountsSettings.self)
        reencode(NavigationSettings.self)
        reencode(ThemeSettings.self)
        reencode(TextEditingSettings.self)
        reencode(TerminalSettings.self)
        reencode(SourceControlSettings.self)
        reencode(KeybindingsSettings.self)
        reencode(SearchSettings.self)
        reencode(LanguageServerSettings.self)
        reencode(DeveloperSettings.self)

        #expect(try parsed(store.encoded()) == parsed(original))
    }

    /// Section keys must match the JSON keys `SettingsData` already uses, or existing settings
    /// files silently orphan their values.
    ///
    /// Note `developerSettings`, not `developer` — the key is the existing field name.
    @Test
    func sectionKeysMatchTheOnDiskKeys() {
        #expect(GeneralSettings.settingsKey == "general")
        #expect(AccountsSettings.settingsKey == "accounts")
        #expect(NavigationSettings.settingsKey == "navigation")
        #expect(ThemeSettings.settingsKey == "theme")
        #expect(TextEditingSettings.settingsKey == "textEditing")
        #expect(TerminalSettings.settingsKey == "terminal")
        #expect(SourceControlSettings.settingsKey == "sourceControl")
        #expect(KeybindingsSettings.settingsKey == "keybindings")
        #expect(SearchSettings.settingsKey == "search")
        #expect(LanguageServerSettings.settingsKey == "languageServers")
        #expect(DeveloperSettings.settingsKey == "developerSettings")
    }

    @Test
    func snapshotReaderReturnsTheGivenSection() {
        var terminal = TerminalSettings()
        terminal.cursorBlink = true
        let reader = SnapshotSettingsReader([TerminalSettings.settingsKey: terminal])

        #expect(reader.value(TerminalSettings.self).cursorBlink == true)
    }

    @Test
    func snapshotReaderFallsBackToDefaults() {
        let reader = SnapshotSettingsReader([:])

        #expect(reader.value(TerminalSettings.self) == TerminalSettings())
    }

    /// Every section present on disk must survive a save, whether or not anything is registered to
    /// read it. This is what keeps a disabled or not-yet-loaded extension's configuration alive.
    @Test
    func unknownSectionsSurviveASave() throws {
        let original = try fixture("unknown-sections")
        let store = try SettingsStore(data: original)
        let saved = try store.encoded()

        let before = try parsed(original)
        let after = try parsed(saved)
        #expect(after["someFutureFeature"] as? NSDictionary == before["someFutureFeature"] as? NSDictionary)
        #expect(after["extensions"] as? NSDictionary == before["extensions"] as? NSDictionary)
    }

    /// A registered section must survive the store's decode/encode cycle with non-default values
    /// intact — not merely be replaced by a section rebuilt at defaults.
    @Test
    func registeredSectionRoundTripsThroughTheStore() throws {
        let store = try SettingsStore(data: fixture("full-settings"))

        var terminal = store[TerminalSettings.self]
        #expect(terminal.cursorBlink == true, "fixture seeds a non-default value")
        terminal.cursorStyle = .underline
        store[TerminalSettings.self] = terminal

        let reloaded = try SettingsStore(data: store.encoded())
        #expect(reloaded[TerminalSettings.self].cursorStyle == .underline)
        #expect(reloaded[TerminalSettings.self].cursorBlink == true, "untouched field survived")
    }

    /// A section this build cannot decode must survive a save untouched for as long as nothing
    /// writes it — reading it as defaults must not make those defaults the stored value.
    @Test
    func anUndecodableSectionIsReEmittedVerbatim() throws {
        let original = Data(#"{"theme":["hand","edited"],"general":{"fileIconStyle":"monochrome"}}"#.utf8)
        let store = try SettingsStore(data: original)

        #expect(store[ThemeSettings.self] == ThemeSettings(), "an unreadable section reads as defaults")

        // A write to an *unrelated* section must not take the broken one down with it.
        var general = store[GeneralSettings.self]
        general.fileIconStyle = .color
        store[GeneralSettings.self] = general

        let after = try parsed(store.encoded())
        #expect(after["theme"] as? NSArray == ["hand", "edited"] as NSArray)
    }

    /// Writing a section whose stored value could not be decoded is the one destructive operation in
    /// the store, and it must announce itself before it happens.
    ///
    /// The handler is what lets `PersistentSettingsStore` copy the file aside first. Asserting on the values
    /// instead would prove nothing: they are the same defaults either way.
    @Test
    func replacingAnUndecodableSectionIsAnnouncedOnce() throws {
        let store = try SettingsStore(data: Data(#"{"theme":[],"general":{}}"#.utf8))

        var announced: [String] = []
        store.willReplaceUndecodableSection = { announced.append($0) }

        // A decodable section is replaced silently — nothing of the user's is lost.
        store[GeneralSettings.self] = store[GeneralSettings.self]
        #expect(announced.isEmpty)

        store[ThemeSettings.self] = store[ThemeSettings.self]
        #expect(announced == ["theme"])

        // The original is gone now, so a repeat write has nothing left to announce.
        store[ThemeSettings.self] = store[ThemeSettings.self]
        #expect(announced == ["theme"])
    }

    /// Loading and saving through `Settings` must not drop sections it has no field for.
    ///
    /// This is the guarantee extensions depend on: a user who disables an extension must not lose
    /// its configuration the next time anything else is saved.
    @Test
    @MainActor
    func savingPreservesSectionsSettingsDataDoesNotKnow() throws {
        let original = try fixture("unknown-sections")
        let store = try SettingsStore(data: original)

        // Simulate the load → mutate a known section → save cycle `Settings` performs.
        var general = store[GeneralSettings.self]
        general.fileIconStyle = .color
        store[GeneralSettings.self] = general

        let after = try parsed(store.encoded())
        let before = try parsed(original)
        #expect(after["someFutureFeature"] as? NSDictionary == before["someFutureFeature"] as? NSDictionary)
        #expect(after["extensions"] as? NSDictionary == before["extensions"] as? NSDictionary)
    }
}
