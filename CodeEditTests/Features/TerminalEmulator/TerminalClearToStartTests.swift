//
//  TerminalClearToStartTests.swift
//  CodeEditTests
//
//  Created for issue #891 — Clear To Start (⌘K) on the integrated terminal.
//

import AppKit
import SwiftTerm
import XCTest
@testable import CodeEdit

final class TerminalClearToStartTests: XCTestCase {

    // MARK: - Settings

    func testClearToStartSettingDefaultsToTrueWhenMissing() throws {
        let json = Data("{}".utf8)
        let settings = try JSONDecoder().decode(SettingsData.TerminalSettings.self, from: json)

        XCTAssertTrue(
            settings.clearToStartOnCommandK,
            "⌘K clear should be enabled by default to match Terminal.app / VS Code"
        )
    }

    func testClearToStartSettingDecodesFalse() throws {
        let json = Data(#"{"clearToStartOnCommandK":false}"#.utf8)
        let settings = try JSONDecoder().decode(SettingsData.TerminalSettings.self, from: json)

        XCTAssertFalse(settings.clearToStartOnCommandK)
    }

    func testClearToStartSettingIsSearchable() {
        let settings = SettingsData.TerminalSettings()
        let keys = settings.searchKeys.map { $0.lowercased() }

        XCTAssertTrue(
            keys.contains(where: { $0.contains("clear to start") }),
            "Expected a searchable label for Clear to Start / ⌘K, got: \(settings.searchKeys)"
        )
    }

    // MARK: - Clear behavior

    @MainActor
    func testClearToStartRemovesViewportAndScrollback() {
        let terminalView = CELocalShellTerminalView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        let terminal = terminalView.getTerminal()

        // Produce more lines than the viewport so scrollback is non-empty.
        for index in 0..<200 {
            terminalView.feed(text: "line-\(index)\n")
        }

        let before = terminal.getText(
            start: Position(col: 0, row: 0),
            end: Position(col: max(0, terminal.cols - 1), row: max(0, terminal.buffer.yDisp + terminal.rows - 1))
        )
        XCTAssertTrue(before.contains("line-"), "Precondition: terminal should contain fed output")

        terminalView.clearToStart()

        XCTAssertEqual(terminal.buffer.x, 0, "Cursor should be at column 0")
        XCTAssertEqual(terminal.buffer.y, 0, "Cursor should be at row 0")
        XCTAssertEqual(terminal.buffer.yDisp, 0, "Viewport should be scrolled to the top")

        let after = terminal.getText(
            start: Position(col: 0, row: 0),
            end: Position(col: max(0, terminal.cols - 1), row: max(0, terminal.rows - 1))
        )
        XCTAssertFalse(
            after.contains("line-"),
            "Cleared terminal should not still show previous output, got: \(after.prefix(200))"
        )

        let visibleText = terminalView.accessibilityValue() as? String ?? ""
        XCTAssertFalse(
            visibleText.contains("line-"),
            "Accessibility value should also be cleared, got: \(visibleText.prefix(200))"
        )
    }
}
