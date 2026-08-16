//
//  SettingsStoreTests.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 16/08/26.
//

import Testing
import Foundation
@testable import CodeEditSettings

/// Guards the two store behaviours nothing else pins.
///
/// Both were previously asserted only in doc comments, and both are load-bearing: the first is what
/// third-party extension settings will rely on, the second is what makes a settings change visible
/// to a view body re-evaluated by the change itself.
struct SettingsStoreTests {

    // MARK: - Preservation

    /// A section nothing in this build decodes must survive a save by this build.
    ///
    /// This is the guarantee an extension's configuration depends on: a newer build writes a key,
    /// an older build loads and saves, and the key is still there afterwards.
    @Test
    func preservesSectionsNoTypeClaims() throws {
        let raw = Data(#"{"general":{"revealFileOnFocusChange":true},"com.example.ext":{"enabled":true}}"#.utf8)

        let store = try SettingsStore(data: raw)
        store[GeneralSettings.self] = store[GeneralSettings.self]

        let object = try #require(
            JSONSerialization.jsonObject(with: try store.encoded()) as? [String: Any]
        )
        let extensionSection = try #require(
            object["com.example.ext"] as? [String: Any],
            "a section no type decodes must survive a write by this build"
        )
        #expect(extensionSection["enabled"] as? Bool == true, "its contents must survive verbatim")
    }

    /// An undecodable section is likewise held verbatim, rather than being dropped or defaulted on
    /// disk, until something writes that same section back.
    @Test
    func preservesASectionThisBuildCannotDecode() throws {
        let raw = Data(#"{"general":"this is not an object","com.example.ext":{"enabled":true}}"#.utf8)

        let store = try SettingsStore(data: raw)
        _ = store[GeneralSettings.self]

        let object = try #require(
            JSONSerialization.jsonObject(with: try store.encoded()) as? [String: Any]
        )
        #expect(
            object["general"] as? String == "this is not an object",
            "reading an undecodable section must not replace it on disk"
        )
    }

    // MARK: - Ordering

    /// Observers must see the **new** value, not the value being replaced.
    ///
    /// `PersistentSettingsStore` mutates its backing store before bumping `revision`, so a view body
    /// re-evaluated by the publish already reads the new value. Inverting that order would make
    /// every settings change appear one edit behind.
    @MainActor
    @Test
    func publishesOnlyAfterTheNewValueIsReadable() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("settings-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }

        let store = PersistentSettingsStore(settingsURL: url)

        var section = store.value(GeneralSettings.self)
        section.revealFileOnFocusChange.toggle()
        let expected = section.revealFileOnFocusChange

        var observed: Bool?
        let token = store.objectWillChange.sink { _ in
            observed = store.value(GeneralSettings.self).revealFileOnFocusChange
        }
        defer { token.cancel() }

        store.setValue(section)

        #expect(observed == expected, "an observer must read the new value, not the one replaced")
    }
}
