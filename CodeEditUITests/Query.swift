//
//  Query.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 7/10/24.
//

import XCTest

enum Query {
    static func getWindow(_ application: XCUIApplication) -> XCUIElement {
        let window = application.windows["CodeEdit"]
        XCTAssertTrue(window.exists, "Window not found")
        return window
    }

    enum Window {
        static func getNavigator(_ window: XCUIElement) -> XCUIElement {
            let navigator = window.descendants(matching: .any).matching(identifier: "ProjectNavigator").element
            XCTAssertTrue(navigator.exists, "Navigator not found")
            return navigator
        }

        static func getTabBar(_ window: XCUIElement) -> XCUIElement {
            let scrollArea = window.descendants(matching: .any).matching(identifier: "TabBar").element
            XCTAssertTrue(scrollArea.exists)
            return scrollArea
        }
    }

    enum Navigator {
        static func getProjectNavigatorRow(fileTitle: String, index: Int = 0, _ navigator: XCUIElement) -> XCUIElement {
            let row = navigator
                .descendants(matching: .outlineRow)
                .containing(.textField, identifier: "ProjectNavigatorTableViewCell-\(fileTitle)")
                .element(boundBy: index)
            XCTAssertTrue(row.exists)
            return row
        }

        static func disclosureIndicatorForRow(_ row: XCUIElement) -> XCUIElement {
            row.descendants(matching: .disclosureTriangle).element
        }

        static func rowContainsDisclosureIndicator(_ row: XCUIElement) -> Bool {
            disclosureIndicatorForRow(row).exists
        }
    }

    enum TabBar {
        static func getTab(labeled title: String, _ tabBar: XCUIElement) -> XCUIElement {
            tabBar.descendants(matching: .group).containing(NSPredicate(format: "value = %@", title)).firstMatch
        }
    }
}
