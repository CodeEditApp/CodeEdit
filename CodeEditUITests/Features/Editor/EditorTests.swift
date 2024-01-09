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
        app.enableTestMode()
        app.speedUpAnimations()
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

        // Test splitting the editor

        window.buttons["SubEditorLayoutView 0"].click()

        let splitGroupsQuery = window.splitGroups.groups.splitGroups.groups.splitGroups
        XCUIElement.perform(withKeyModifiers: .option) {
            splitGroupsQuery.groups.containing(.button, identifier: "SubEditorLayoutView 1").buttons["Split Vertically"].click()
        }

        splitGroupsQuery.groups.containing(.button, identifier: "Split Horizontally").buttons["Close this Editor"].click()
        splitGroupsQuery.groups.splitGroups.groups.containing(.button, identifier: "SubEditorLayoutView 1").buttons["Close this Editor"].click()

        // Test focusing an editor

        window.buttons["SubEditorLayoutView 0"].click()

        XCUIElement.perform(withKeyModifiers: .option) {
            splitGroupsQuery.groups.containing(.button, identifier: "SubEditorLayoutView 1").buttons["Split Vertically"].click()
        }

        let splitGroupsQuery2 = splitGroupsQuery.groups.splitGroups
        splitGroupsQuery2.groups.containing(.button, identifier: "SubEditorLayoutView 0").buttons["Focus this Editor"].click()
        window.buttons["Unfocus this Editor"].click()
        splitGroupsQuery2.groups.containing(.button, identifier: "SubEditorLayoutView 1").buttons["Close this Editor"].click()
        splitGroupsQuery.groups.containing(.button, identifier: "SubEditorLayoutView 0").buttons["Close this Editor"].click()

        // Open a file

        window.outlines.children(matching: .outlineRow).element(boundBy: 2).cells.element.click()

        // Close the temporary file

        // Open the file again, make it permanent and open another file

        //
    }

    // swiftlint:enable line_length
}
