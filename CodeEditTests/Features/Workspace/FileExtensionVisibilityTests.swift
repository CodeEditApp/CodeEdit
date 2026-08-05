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

/// Covers `CEWorkspaceFile.labelFileName()`, which had no tests despite driving every
/// Project Navigator row label. Mutates the `Settings.shared` singleton, so the original
/// general settings are restored in `tearDown`.
final class FileExtensionVisibilityTests: XCTestCase {

    private var original: SettingsData.GeneralSettings!

    override func setUp() {
        super.setUp()
        original = Settings.shared.preferences.general
    }

    override func tearDown() {
        Settings.shared.preferences.general = original
        original = nil
        super.tearDown()
    }

    private func label(_ filename: String) -> String {
        CEWorkspaceFile(url: URL(filePath: "/tmp/\(filename)")).labelFileName()
    }

    func testShowAllKeepsEveryExtension() {
        Settings.shared.preferences.general.fileExtensionsVisibility = .showAll
        XCTAssertEqual(label("notes.txt"), "notes.txt")
        XCTAssertEqual(label("Model.swift"), "Model.swift")
    }

    func testHideAllStripsEveryExtension() {
        Settings.shared.preferences.general.fileExtensionsVisibility = .hideAll
        XCTAssertEqual(label("notes.txt"), "notes")
        XCTAssertEqual(label("Model.swift"), "Model")
    }

    func testShowOnlyKeepsListedAndStripsTheRest() {
        Settings.shared.preferences.general.fileExtensionsVisibility = .showOnly
        Settings.shared.preferences.general.shownFileExtensions.extensions = ["swift"]
        XCTAssertEqual(label("Model.swift"), "Model.swift")
        XCTAssertEqual(label("notes.txt"), "notes")
    }

    func testHideOnlyStripsListedAndKeepsTheRest() {
        Settings.shared.preferences.general.fileExtensionsVisibility = .hideOnly
        Settings.shared.preferences.general.hiddenFileExtensions.extensions = ["swift"]
        XCTAssertEqual(label("Model.swift"), "Model")
        XCTAssertEqual(label("notes.txt"), "notes.txt")
    }

    /// Regression for 2715e319. Matching used to compare `FileType.rawValue`, whose value for
    /// `.txt` was the string `"text"` — so entering `txt` never matched anything.
    func testTxtIsMatchableByItsRealExtension() {
        Settings.shared.preferences.general.fileExtensionsVisibility = .showOnly
        Settings.shared.preferences.general.shownFileExtensions.extensions = ["txt"]
        XCTAssertEqual(label("notes.txt"), "notes.txt")
        XCTAssertEqual(label("Model.swift"), "Model")
    }

    /// Regression for 2715e319. Extensions absent from the old `FileType` enum all fell back to
    /// `.txt` and reported themselves as `"text"`, so the preference could never match them.
    func testExtensionsAbsentFromTheOldEnumAreMatchable() {
        Settings.shared.preferences.general.fileExtensionsVisibility = .hideOnly
        Settings.shared.preferences.general.hiddenFileExtensions.extensions = ["toml"]
        XCTAssertEqual(label("Config.toml"), "Config")
        XCTAssertEqual(label("notes.txt"), "notes.txt")
    }

    func testExtensionlessNamesAreUnaffected() {
        for mode in [SettingsData.FileExtensionsVisibility.hideAll, .showAll] {
            Settings.shared.preferences.general.fileExtensionsVisibility = mode
            XCTAssertEqual(label("LICENSE"), "LICENSE", "mode \(mode)")
            XCTAssertEqual(label("Makefile"), "Makefile", "mode \(mode)")
        }
    }
}
