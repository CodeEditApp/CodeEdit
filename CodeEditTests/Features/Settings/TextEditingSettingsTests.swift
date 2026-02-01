//
//  TextEditingSettingsTests.swift
//  CodeEditTests
//
//  Tests for Text Editing settings, including wrapped line indent (CodeEditTextView #18).
//

import Foundation
import Testing
@testable import CodeEdit

@Suite("Text Editing Settings")
struct TextEditingSettingsTests {

    // MARK: - Wrapped line indent (indent wrapped lines - CodeEditTextView #18)

    @Test("Default wrapped line indent is 4 spaces")
    func defaultWrappedLineIndentIsFour() {
        let settings = SettingsData.TextEditingSettings()
        #expect(settings.wrappedLineIndent == 4)
    }

    @Test("Wrapped line indent round-trips through Codable")
    func wrappedLineIndentRoundTrips() throws {
        var settings = SettingsData.TextEditingSettings()
        settings.wrappedLineIndent = 12

        let encoded = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(SettingsData.TextEditingSettings.self, from: encoded)
        #expect(decoded.wrappedLineIndent == 12)
    }

    @Test("Decode with missing wrappedLineIndent uses default 4")
    func decodeMissingWrappedLineIndentUsesDefault() throws {
        // JSON without wrappedLineIndent key (e.g. existing user preferences)
        let json = """
        {"wrapLinesToEditorWidth": true}
        """
        let data = json.data(using: .utf8)!
        // Decode a minimal object; TextEditingSettings init(from:) decodes each key with default
        let decoded = try JSONDecoder().decode(SettingsData.TextEditingSettings.self, from: data)
        #expect(decoded.wrappedLineIndent == 4)
    }

    @Test("Wrapped line indent accepts valid range 0–24")
    func wrappedLineIndentValidRange() throws {
        for value in [0, 4, 8, 12, 24] {
            var settings = SettingsData.TextEditingSettings()
            settings.wrappedLineIndent = value
            let encoded = try JSONEncoder().encode(settings)
            let decoded = try JSONDecoder().decode(SettingsData.TextEditingSettings.self, from: encoded)
            #expect(decoded.wrappedLineIndent == value)
        }
    }

    @Test("Wrap lines to editor width default is true")
    func wrapLinesToEditorWidthDefault() {
        let settings = SettingsData.TextEditingSettings()
        #expect(settings.wrapLinesToEditorWidth == true)
    }
}
