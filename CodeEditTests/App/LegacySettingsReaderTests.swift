//
//  LegacySettingsReaderTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import Foundation
import Testing
import CodeEditSettings
@testable import CodeEdit

/// Verifies `LegacySettingsReader` actually reads through to `Settings.shared`, rather than
/// answering with section defaults like `DefaultSettingsReader` would. A test that only checked
/// defaults would pass against either reader and prove nothing about the bridge.
struct LegacySettingsReaderTests {
    @Test
    func readsMutatedValueFromTheSingleton() throws {
        let originalValue = Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled
        defer {
            Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled = originalValue
        }

        // Non-default: `SourceControlGeneral.sourceControlIsEnabled` defaults to `true`, so
        // `DefaultSettingsReader` (or an unmapped fallback) would never produce `false` here.
        Settings.shared.preferences.sourceControl.general.sourceControlIsEnabled = false

        let reader: SettingsReading = LegacySettingsReader()
        #expect(reader.value(SourceControlSettings.self).general.sourceControlIsEnabled == false)
    }
}
