//
//  FileExtensionVisibilityTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 05/08/2026.
//

import XCTest
import CodeEditCore
import CodeEditSettings
@testable import CodeEdit

/// Covers `CEWorkspaceFile.labelFileName(_:)`, which had no tests despite driving every
/// Project Navigator row label.
///
/// It used to mutate the `Settings.shared` singleton and restore it in `tearDown`; the settings it
/// reads are now a parameter, so each case builds the exact `GeneralSettings` it means and no
/// process-wide state is touched.
final class FileExtensionVisibilityTests: XCTestCase {

    private func settings(
        _ visibility: GeneralSettings.FileExtensionsVisibility,
        shown: [String] = [],
        hidden: [String] = []
    ) -> GeneralSettings {
        var settings = GeneralSettings()
        settings.fileExtensionsVisibility = visibility
        settings.shownFileExtensions.extensions = shown
        settings.hiddenFileExtensions.extensions = hidden
        return settings
    }

    private func label(_ filename: String, _ settings: GeneralSettings) -> String {
        CEWorkspaceFile(url: URL(filePath: "/tmp/\(filename)")).labelFileName(settings)
    }

    func testShowAllKeepsEveryExtension() {
        let settings = settings(.showAll)
        XCTAssertEqual(label("notes.txt", settings), "notes.txt")
        XCTAssertEqual(label("Model.swift", settings), "Model.swift")
    }

    func testHideAllStripsEveryExtension() {
        let settings = settings(.hideAll)
        XCTAssertEqual(label("notes.txt", settings), "notes")
        XCTAssertEqual(label("Model.swift", settings), "Model")
    }

    func testShowOnlyKeepsListedAndStripsTheRest() {
        let settings = settings(.showOnly, shown: ["swift"])
        XCTAssertEqual(label("Model.swift", settings), "Model.swift")
        XCTAssertEqual(label("notes.txt", settings), "notes")
    }

    func testHideOnlyStripsListedAndKeepsTheRest() {
        let settings = settings(.hideOnly, hidden: ["swift"])
        XCTAssertEqual(label("Model.swift", settings), "Model")
        XCTAssertEqual(label("notes.txt", settings), "notes.txt")
    }

    /// Regression for 2715e319. Matching used to compare `FileType.rawValue`, whose value for
    /// `.txt` was the string `"text"` — so entering `txt` never matched anything.
    func testTxtIsMatchableByItsRealExtension() {
        let settings = settings(.showOnly, shown: ["txt"])
        XCTAssertEqual(label("notes.txt", settings), "notes.txt")
        XCTAssertEqual(label("Model.swift", settings), "Model")
    }

    /// Regression for 2715e319. Extensions absent from the old `FileType` enum all fell back to
    /// `.txt` and reported themselves as `"text"`, so the preference could never match them.
    func testExtensionsAbsentFromTheOldEnumAreMatchable() {
        let settings = settings(.hideOnly, hidden: ["toml"])
        XCTAssertEqual(label("Config.toml", settings), "Config")
        XCTAssertEqual(label("notes.txt", settings), "notes.txt")
    }

    func testExtensionlessNamesAreUnaffected() {
        for mode in [GeneralSettings.FileExtensionsVisibility.hideAll, .showAll] {
            let settings = settings(mode)
            XCTAssertEqual(label("LICENSE", settings), "LICENSE", "mode \(mode)")
            XCTAssertEqual(label("Makefile", settings), "Makefile", "mode \(mode)")
        }
    }
}
