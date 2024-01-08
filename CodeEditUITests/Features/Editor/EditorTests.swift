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
    }

    override func tearDown() async throws {
        try TestWorkspace.tearDown()
    }

    func testEditorUI() throws {
        let app = XCUIApplication()
        app.enableTestMode()
        app.speedUpAnimations()
        app.openTestWorkspace(root: workspaceURL)
        app.launch()

        // Splitting the editor


        // Focusing

        // Use the


    }
}
