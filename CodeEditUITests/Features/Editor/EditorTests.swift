//
//  EditorTests.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 1/6/24.
//

import XCTest
import SnapshotTesting

final class EditorTests: XCTestCase {
    var workspaceURL: URL!

    override func setUpWithError() throws {
        continueAfterFailure = false

        try workspaceURL = TestWorkspace.setUp()

        let app = XCUIApplication()
        app.openTestWorkspace(root: workspaceURL)
        app.launch()
    }

    override func tearDown() async throws {
        try TestWorkspace.tearDown()
    }

    // swiftlint:disable line_length

    func testEditorView() throws {
        let app = XCUIApplication()
        let window = app.windows["UITestWorkspace"]

        window.toolbars.element.click()

        // Open a file
        // Needs bugfix PR first.
        //        window.outlines.children(matching: .outlineRow).element(boundBy: 2).cells.element.click()

        // Test splitting the editor

        let editorAreaQuery = window.groups.splitGroups.groups.splitGroups.groups.element(boundBy: 0)

        let splitGroupsQuery = window.splitGroups.groups.splitGroups.groups.splitGroups
        splitGroupsQuery.children(matching: .group).element(boundBy: 0).buttons["Split Horizontally"].click()
        XCUIElement.perform(withKeyModifiers: .option) {
            splitGroupsQuery.children(matching: .group).element(boundBy: 0).buttons["Split Vertically"].click()
        }

        XCTAssertTrue(splitGroupsQuery.groups.containing(.button, identifier: "Split Horizontally").buttons["Close this Editor"].exists)
        assertSnapshot(
            of: editorAreaQuery.normalizedScreenshot(),
            as: .image(perceptualPrecision: 0.98),
            named: "All Splits"
        )

        splitGroupsQuery.groups.containing(.button, identifier: "Split Horizontally").buttons["Close this Editor"].click()

        // Assert after closing one editor
        XCTAssertTrue(splitGroupsQuery.groups.splitGroups.groups.element(boundBy: 1).buttons["Close this Editor"].exists)
        assertSnapshot(
            of: editorAreaQuery.normalizedScreenshot(),
            as: .image(perceptualPrecision: 0.98),
            named: "One Split"
        )

        splitGroupsQuery.groups.splitGroups.groups.element(boundBy: 1).buttons["Close this Editor"].click()
        window.staticTexts["No Editor"].click()

        // Assert that the editor is the same after closing all splits
        assertSnapshot(
            of: editorAreaQuery.normalizedScreenshot(),
            as: .image(perceptualPrecision: 0.98),
            named: "No Splits"
        )

        // Test focusing an editor

        splitGroupsQuery.children(matching: .group).element(boundBy: 0).buttons["Split Horizontally"].click()
        XCUIElement.perform(withKeyModifiers: .option) {
            splitGroupsQuery.children(matching: .group).element(boundBy: 0).buttons["Split Vertically"].click()
        }

        let splitGroupsQuery2 = splitGroupsQuery.groups.splitGroups
        splitGroupsQuery2.groups.element(boundBy: 1).buttons["Focus this Editor"].click()

        XCTAssertTrue(window.buttons["Unfocus this Editor"].exists)
        assertSnapshot(
            of: editorAreaQuery.normalizedScreenshot(),
            as: .image(perceptualPrecision: 0.98),
            named: "Focused Editor"
        )

        window.buttons["Unfocus this Editor"].click()
        splitGroupsQuery.groups.containing(.button, identifier: "Split Horizontally").buttons["Close this Editor"].click()
        splitGroupsQuery.groups.splitGroups.groups.element(boundBy: 1).buttons["Close this Editor"].click()

        assertSnapshot(
            of: editorAreaQuery.normalizedScreenshot(),
            as: .image(perceptualPrecision: 0.98),
            named: "No Splits"
        )
    }

    // swiftlint:enable line_length
}
