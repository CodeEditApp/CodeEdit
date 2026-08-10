//
//  SettingsFormatTests.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

import Testing
import Foundation
import CESourceControl
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
