//
//  ProjectNavigatorFileManagementUITests.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 1/15/25.
//

import XCTest

final class ProjectNavigatorFileManagementUITests: XCTestCase {

    var app: XCUIApplication!
    var window: XCUIElement!
    var navigator: XCUIElement!
    var path: String!

    override func setUp() async throws {
        // MainActor required for async compatibility which is required to make this method throwing
        try await MainActor.run {
            (app, path) = try App.launchWithTempDir()

            window = Query.getWindow(app)
            XCTAssertTrue(window.exists, "Window not found")
            window.toolbars.firstMatch.click()

            navigator = Query.Window.getProjectNavigator(window)
            XCTAssertTrue(navigator.exists, "Navigator not found")
            XCTAssertEqual(Query.Navigator.getRows(navigator).count, 1, "Found more than just the root file.")
        }
    }

    func testNewFilesAppear() throws {
        // Create a few files, one in the base path and one inside a new folder. They should all appear in the navigator

        guard FileManager.default.createFile(atPath: path.appending("/newFile.txt"), contents: nil) else {
            XCTFail("Failed to create test file")
            return
        }

        try FileManager.default.createDirectory(
            atPath: path.appending("/New Folder"),
            withIntermediateDirectories: true
        )

        guard FileManager.default.createFile(
            atPath: path.appending("/New Folder/My New JS File.jsx"),
            contents: nil
        ) else {
            XCTFail("Failed to create second test file")
            return
        }

        guard Query.Navigator.getProjectNavigatorRow(
            fileTitle: "newFile.txt",
            navigator
        ).waitForExistence(timeout: 2.0) else {
            XCTFail("newFile.txt did not appear")
            return
        }

        guard Query.Navigator.getProjectNavigatorRow(
            fileTitle: "New Folder",
            navigator
        ).waitForExistence(timeout: 2.0) else {
            XCTFail("New Folder did not appear")
            return
        }

        let folderRow = Query.Navigator.getProjectNavigatorRow(fileTitle: "New Folder", navigator)
        folderRow.disclosureTriangles.element.click()

        guard Query.Navigator.getProjectNavigatorRow(
            fileTitle: "My New JS File.jsx",
            navigator
        ).waitForExistence(timeout: 2.0) else {
            XCTFail("New file inside the folder did not appear when folder was opened.")
            return
        }
    }

    func testCreateNewFiles() throws {
        // Add a few files with the navigator button
        for idx in 0..<5 {
            let addButton = window.popUpButtons["addButton"]
            addButton.click()
            let addMenu = addButton.menus.firstMatch
            addMenu.menuItems["Add File"].click()

            let selectedRows = Query.Navigator.getSelectedRows(navigator)
            guard selectedRows.firstMatch.waitForExistence(timeout: 0.5) else {
                XCTFail("No new selected rows appeared")
                return
            }

            let title = idx > 0 ? "untitled\(idx)" : "untitled"

            let newFileRow = selectedRows.firstMatch
            XCTAssertEqual(newFileRow.descendants(matching: .textField).firstMatch.value as? String, title)

            let tabBar = Query.Window.getTabBar(window)
            XCTAssertTrue(tabBar.exists)
            let readmeTab = Query.TabBar.getTab(labeled: title, tabBar)
            XCTAssertTrue(readmeTab.exists)

            let newFileEditor = Query.Window.getFirstEditor(window)
            XCTAssertTrue(newFileEditor.exists)
            XCTAssertNotNil(newFileEditor.value as? String)
        }
    }
}
