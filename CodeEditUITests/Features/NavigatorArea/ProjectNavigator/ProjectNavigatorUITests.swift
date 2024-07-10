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
        application = XCUIApplication()
        application.launchArguments = ["--open", projectPath()]
        application.launch()
    }

    func testNavigatorOpenFilesAndFolder() {
        let window = Query.getWindow(application)
        // Focus the window
        window.toolbars.firstMatch.click()

        // Get the navigator
        let navigator = Query.Window.getNavigator(window)

        // Open the README.md
        let readmeRow = Query.Navigator.getProjectNavigatorRow(fileTitle: "README.md", navigator)
        XCTAssertFalse(Query.Navigator.rowContainsDisclosureIndicator(readmeRow), "File has disclosure indicator")
        readmeRow.click()

        let tabBar = Query.Window.getTabBar(window)
        let readmeTab = Query.TabBar.getTab(labeled: "README.md", tabBar)
        XCTAssertTrue(readmeTab.exists)

        let rowCount = navigator.descendants(matching: .outlineRow).count

        // Open a folder
        let codeEditFolderRow = Query.Navigator.getProjectNavigatorRow(fileTitle: "CodeEdit", index: 1, navigator)
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
