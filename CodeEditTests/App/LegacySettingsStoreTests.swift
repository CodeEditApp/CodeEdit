//
//  LegacySettingsStoreTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import Foundation
import Testing
import CodeEditSettings
@testable import CodeEdit

/// Verifies `LegacySettingsStore` actually reads and writes through to `Settings.shared`, rather
/// than answering with section defaults like `DefaultSettingsReader` would. A test that only
/// checked defaults would pass against either implementation and prove nothing about the bridge.
///
/// These tests mutate a process-wide singleton, so each one restores what it found. They are
/// `@MainActor` and `.serialized` because `Settings` is an `ObservableObject` with live SwiftUI
/// observers in the test host: mutating `preferences` off the main thread drives an AppKit update
/// from a cooperative-pool thread and trips the Main Thread Checker, and two of them running
/// concurrently would also race on the save/restore of the same field.
@MainActor
@Suite(.serialized)
struct LegacySettingsStoreTests {
    @Test
    func readsMutatedValueFromTheSingleton() throws {
        let originalValue = Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled
        defer {
            Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled = originalValue
        }

        // Non-default: `SourceControlGeneral.sourceControlIsEnabled` defaults to `true`, so
        // `DefaultSettingsReader` (or an unmapped fallback) would never produce `false` here.
        Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled = false

        let store: SettingsReading = LegacySettingsStore()
        #expect(store.value(SourceControlSettings.self).general.sourceControlIsEnabled == false)
    }

    @Test
    func writtenSectionReachesTheSingletonAndReadsBack() throws {
        let originalValue = Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled
        defer {
            Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled = originalValue
        }
        // Start from the default so the assertion below cannot pass on pre-existing state.
        Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled = true

        let store: SettingsAccessing = LegacySettingsStore()
        var section = store.value(SourceControlSettings.self)
        section.general.sourceControlIsEnabled = false
        store.setValue(section)

        // Round trip through the seam...
        #expect(store.value(SourceControlSettings.self).general.sourceControlIsEnabled == false)
        // ...and, crucially, into `Settings.shared.preferences` itself, which is what the
        // `@Published` → throttle → `savePreferences` pipeline persists. A write that only
        // mutated a copy would pass the line above and still lose the value on relaunch.
        #expect(Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled == false)
    }

    @Test
    func writtenSectionIsVisibleToAnIndependentReader() throws {
        let original = Settings.shared.preferences.languageServers.installedLanguageServers
        defer {
            Settings.shared.preferences.languageServers.installedLanguageServers = original
        }
        Settings.shared.preferences.languageServers.installedLanguageServers = [:]

        let writer: SettingsAccessing = LegacySettingsStore()
        var section = writer.value(LanguageServerSettings.self)
        section.installedLanguageServers = [
            "round-trip-test": .init(packageName: "round-trip-test", isEnabled: false, version: "9.9.9")
        ]
        writer.setValue(section)

        // A *different* instance, to prove the value lives in the store and not in the writer.
        let reader: SettingsReading = LegacySettingsStore()
        let readBack = reader.value(LanguageServerSettings.self).installedLanguageServers["round-trip-test"]
        #expect(readBack?.version == "9.9.9")
        #expect(readBack?.isEnabled == false)
    }
}
