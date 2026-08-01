//
//  SidebarPanelRetentionUITests.swift
//  CodeEditUITests
//
//  Created by Boris Serzhanovich on 1/8/26.
//

import XCTest

/// UI regression for #711 — navigator expand state must survive switching sidebar tabs.
final class SidebarPanelRetentionUITests: XCTestCase {

    var application: XCUIApplication!

    override func setUp() {
        application = App.launchWithCodeEditWorkspace()
    }

    func testProjectNavigatorKeepsExpansionAfterSidebarTabSwitch() {
        let window = Query.getWindow(application)
        XCTAssertTrue(window.exists, "Window not found")
        window.toolbars.firstMatch.click()

        let navigator = Query.Window.getProjectNavigator(window)
        XCTAssertTrue(navigator.waitForExistence(timeout: 2.0), "Navigator not found")

        let codeEditFolderRow = Query.Navigator.getProjectNavigatorRow(fileTitle: "CodeEdit", index: 1, navigator)
        XCTAssertTrue(codeEditFolderRow.exists)
        let folderDisclosureIndicator = Query.Navigator.disclosureIndicatorForRow(codeEditFolderRow)
        XCTAssertTrue(folderDisclosureIndicator.exists)

        let collapsedRowCount = navigator.descendants(matching: .outlineRow).count
        folderDisclosureIndicator.click()
        let expandedRowCount = navigator.descendants(matching: .outlineRow).count
        XCTAssertTrue(expandedRowCount > collapsedRowCount, "Folder did not expand")

        // Switch away to Search, then back to Project.
        let searchTab = window.buttons["WorkspacePanelTab-Search"]
        XCTAssertTrue(searchTab.waitForExistence(timeout: 2.0), "Search navigator tab not found")
        searchTab.click()

        let projectTab = window.buttons["WorkspacePanelTab-Project"]
        XCTAssertTrue(projectTab.waitForExistence(timeout: 2.0), "Project navigator tab not found")
        projectTab.click()

        let navigatorAfter = Query.Window.getProjectNavigator(window)
        XCTAssertTrue(navigatorAfter.waitForExistence(timeout: 2.0))
        let restoredRowCount = navigatorAfter.descendants(matching: .outlineRow).count
        XCTAssertEqual(
            restoredRowCount,
            expandedRowCount,
            "Project navigator lost expansion state after switching sidebar tabs"
        )
    }
}
