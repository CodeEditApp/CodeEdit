//
//  ProjectNavigatorUITests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 7/9/24.
//

import XCTest

final class ProjectNavigatorUITests: XCTestCase {

    var application: XCUIApplication!

    override func setUp() {
        application = App.launchWithCodeEditWorkspace()
    }

    func testNavigatorOpenFilesAndFolder() {
        let window = Query.getWindow(application)
        XCTAssertTrue(window.exists, "Window not found")
        // Focus the window
        window.toolbars.firstMatch.click()

        // Get the navigator
        let navigator = Query.Window.getProjectNavigator(window)
        XCTAssertTrue(navigator.exists, "Navigator not found")

        // Open the README.md
        let readmeRow = Query.Navigator.getProjectNavigatorRow(fileTitle: "README.md", navigator)
        XCTAssertFalse(Query.Navigator.rowContainsDisclosureIndicator(readmeRow), "File has disclosure indicator")
        readmeRow.click()

        let tabBar = Query.Window.getTabBar(window)
        XCTAssertTrue(tabBar.exists)
        let readmeTab = Query.TabBar.getTab(labeled: "README.md", tabBar)
        XCTAssertTrue(readmeTab.exists)

        let readmeEditor = Query.Window.getFirstEditor(window)
        XCTAssertTrue(readmeEditor.exists)
        XCTAssertNotNil(readmeEditor.value as? String)

        let rowCount = navigator.descendants(matching: .outlineRow).count

        // Open a folder
        let codeEditFolderRow = Query.Navigator.getProjectNavigatorRow(fileTitle: "CodeEdit", index: 1, navigator)
        XCTAssertTrue(codeEditFolderRow.exists)
        XCTAssertTrue(
            Query.Navigator.rowContainsDisclosureIndicator(codeEditFolderRow),
            "Folder doesn't have disclosure indicator"
        )
        let folderDisclosureIndicator = Query.Navigator.disclosureIndicatorForRow(codeEditFolderRow)
        folderDisclosureIndicator.click()

        let newRowCount = navigator.descendants(matching: .outlineRow).count
        XCTAssertTrue(newRowCount > rowCount, "No new rows were loaded after opening the folder")

        folderDisclosureIndicator.click()
        let finalRowCount = navigator.descendants(matching: .outlineRow).count
        XCTAssertTrue(newRowCount > finalRowCount, "Rows were not hidden after closing a folder")
        XCTAssertEqual(rowCount, finalRowCount, "Different Number of rows loaded")
    }
}
