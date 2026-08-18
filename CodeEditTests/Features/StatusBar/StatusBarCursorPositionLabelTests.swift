//
//  StatusBarCursorPositionLabelTests.swift
//  CodeEditTests
//
//  Created by Boris Serzhanovich on 1/8/26.
//

import XCTest
import AppKit
import CodeEditSourceEditor
@testable import CodeEdit

final class StatusBarCursorPositionLabelTests: XCTestCase {

    func testLabelForSingleCursorUsesLineAndColumn() {
        let label = StatusBarCursorPositionLabel.formatLabel(
            cursorPositions: [CursorPosition(line: 12, column: 4)],
            optionKeyPressed: false,
            linesInRange: { _ in 0 }
        )
        XCTAssertEqual(label, "Line: 12  Col: 4")
    }

    func testLabelFallsBackWhenLineColumnUnresolved() {
        let label = StatusBarCursorPositionLabel.formatLabel(
            cursorPositions: [CursorPosition(range: NSRange(location: 10, length: 0))],
            optionKeyPressed: false,
            linesInRange: { _ in 0 }
        )
        XCTAssertEqual(label, "Line: 1  Col: 1")
    }

    func testLabelForMultipleSelections() {
        let label = StatusBarCursorPositionLabel.formatLabel(
            cursorPositions: [
                CursorPosition(line: 1, column: 1),
                CursorPosition(line: 2, column: 1)
            ],
            optionKeyPressed: false,
            linesInRange: { _ in 0 }
        )
        XCTAssertEqual(label, "2 selected ranges")
    }

    func testLabelForEmptyPositionsIsEmpty() {
        let label = StatusBarCursorPositionLabel.formatLabel(
            cursorPositions: [],
            optionKeyPressed: false,
            linesInRange: { _ in 0 }
        )
        XCTAssertEqual(label, "")
    }

    func testLabelForResolvedCharacterSelection() {
        let label = StatusBarCursorPositionLabel.formatLabel(
            cursorPositions: [CursorPosition(line: 1, column: 1)],
            optionKeyPressed: false,
            linesInRange: { _ in 0 }
        )
        // Length 0 caret → line/col path
        XCTAssertEqual(label, "Line: 1  Col: 1")
    }

    func testLabelUsesOptionKeyCharacterOffset() {
        let label = StatusBarCursorPositionLabel.formatLabel(
            cursorPositions: [CursorPosition(range: NSRange(location: 42, length: 0))],
            optionKeyPressed: true,
            linesInRange: { _ in 0 }
        )
        XCTAssertEqual(label, "Char: 42 Len: 0")
    }
}
