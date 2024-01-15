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
        isRecording = true
//        continueAfterFailure = false

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

        // Open a file
        // Needs bugfix PR first.
        //        window.outlines.children(matching: .outlineRow).element(boundBy: 2).cells.element.click()

        // Test splitting the editor

        let editorAreaQuery = window.groups.splitGroups.groups.splitGroups.groups.element(boundBy: 0)

        let originalWorkspaceImage = editorAreaQuery.screenshot().pngRepresentation

        let splitGroupsQuery = window.splitGroups.groups.splitGroups.groups.splitGroups
        splitGroupsQuery.children(matching: .group).element(boundBy: 0).buttons["Split Horizontally"].click()
        XCUIElement.perform(withKeyModifiers: .option) {
            splitGroupsQuery.children(matching: .group).element(boundBy: 0).buttons["Split Vertically"].click()
        }

        XCTAssertTrue(splitGroupsQuery.groups.containing(.button, identifier: "Split Horizontally").buttons["Close this Editor"].exists)
        assertSnapshot(of: editorAreaQuery.screenshot().image, as: .image)

        splitGroupsQuery.groups.containing(.button, identifier: "Split Horizontally").buttons["Close this Editor"].click()

        XCTAssertTrue(splitGroupsQuery.groups.splitGroups.groups.element(boundBy: 1).buttons["Close this Editor"].exists)
        assertSnapshot(of: editorAreaQuery.screenshot().image, as: .image)

        splitGroupsQuery.groups.splitGroups.groups.element(boundBy: 1).buttons["Close this Editor"].click()

        XCTAssertEqual(originalWorkspaceImage, editorAreaQuery.screenshot().pngRepresentation)

        // Test focusing an editor

        splitGroupsQuery.children(matching: .group).element(boundBy: 0).buttons["Split Horizontally"].click()
        XCUIElement.perform(withKeyModifiers: .option) {
            splitGroupsQuery.children(matching: .group).element(boundBy: 0).buttons["Split Vertically"].click()
        }

        let splitGroupsQuery2 = splitGroupsQuery.groups.splitGroups
        splitGroupsQuery2.groups.element(boundBy: 1).buttons["Focus this Editor"].click()

        XCTAssertTrue(window.buttons["Unfocus this Editor"].exists)
        assertSnapshot(of: editorAreaQuery.screenshot().image, as: .image)

        window.buttons["Unfocus this Editor"].click()
        splitGroupsQuery.groups.containing(.button, identifier: "Split Horizontally").buttons["Close this Editor"].click()
        splitGroupsQuery.groups.splitGroups.groups.element(boundBy: 1).buttons["Close this Editor"].click()

        XCTAssertEqual(originalWorkspaceImage, editorAreaQuery.screenshot().pngRepresentation)
    }

    // swiftlint:enable line_length
}
