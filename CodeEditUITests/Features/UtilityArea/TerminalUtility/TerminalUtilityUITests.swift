//
//  TerminalUtilityUITests.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 8/8/25.
//

import XCTest

final class TerminalUtilityUITests: XCTestCase {
    var app: XCUIApplication!
    var window: XCUIElement!
    var utilityArea: XCUIElement!
    var path: String!

    override func setUp() async throws {
        // MainActor required for async compatibility which is required to make this method throwing
        try await MainActor.run {
            (app, path) = try App.launchWithTempDir()

            window = Query.getWindow(app)
            XCTAssertTrue(window.exists, "Window not found")
            window.toolbars.firstMatch.click()

            utilityArea = Query.Window.getUtilityArea(window)
            XCTAssertTrue(utilityArea.exists, "Utility Area not found")
        }
    }

    func testTerminalsInputData() throws {
        let terminal = utilityArea.textViews["Terminal Emulator"]
        XCTAssertTrue(terminal.exists)
        terminal.click()
        terminal.typeText("echo hello world")
        terminal.typeKey(.enter, modifierFlags: [])

        let value = try XCTUnwrap(terminal.value as? String)
        XCTAssertEqual(value.components(separatedBy: "hello world").count - 1, 2)
    }

    func testTerminalsKeepData() throws {
        var terminal = utilityArea.textViews["Terminal Emulator"]
        XCTAssertTrue(terminal.exists)
        terminal.click()
        terminal.typeText("echo hello world")
        terminal.typeKey(.enter, modifierFlags: [])

        let terminals = utilityArea.descendants(matching: .any).matching(identifier: "terminalsList").element
        XCTAssertTrue(terminals.exists)
        terminals.click()

        let terminalRow = terminals.cells.firstMatch
        XCTAssertTrue(terminalRow.exists)
        terminalRow.click()

        terminal = utilityArea.textViews["Terminal Emulator"]
        XCTAssertTrue(terminal.exists)

        let finalValue = try XCTUnwrap(terminal.value as? String)
        XCTAssertEqual(finalValue.components(separatedBy: "hello world").count - 1, 2)
    }
}
