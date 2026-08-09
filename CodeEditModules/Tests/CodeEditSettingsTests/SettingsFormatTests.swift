//
//  SettingsFormatTests.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

import Testing
import Foundation
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
    @Test
    func fullSettingsRoundTripsUnchanged() throws {
        let original = try fixture("full-settings")
        let decoded = try JSONDecoder().decode(SettingsData.self, from: original)
        let reencoded = try JSONEncoder().encode(decoded)

        #expect(try parsed(reencoded) == parsed(original))
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

    /// Every section present on disk must survive a save, whether or not anything is registered to
    /// read it. This is what keeps a disabled or not-yet-loaded extension's configuration alive.
    ///
    /// The body is commented out rather than merely disabled because `SettingsStore` does not exist
    /// yet and a `.disabled` trait does not prevent compilation. Task 9 introduces the store,
    /// uncomments this, and drops the trait.
    @Test(.disabled("Target behaviour introduced in Task 9: SettingsStore preservation"))
    func unknownSectionsSurviveASave() throws {
//        let original = try fixture("unknown-sections")
//        let store = try SettingsStore(data: original)
//        let saved = try store.encoded()
//
//        let before = try parsed(original)
//        let after = try parsed(saved)
//        #expect(after["someFutureFeature"] as? NSDictionary == before["someFutureFeature"] as? NSDictionary)
//        #expect(after["extensions"] as? NSDictionary == before["extensions"] as? NSDictionary)
    }
}
