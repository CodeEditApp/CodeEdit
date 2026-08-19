//
//  Query.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 7/10/24.
//

import XCTest

/// Query helpers for querying for specific UI elements. Organized by category in the app.
/// Queries should not evaluate if an element exists. This allows for tests to expect an element to exist,
/// perform an action, and then wait for that element to exist.
enum Query {
    static func getWindow(_ application: XCUIApplication, named: String? = nil) -> XCUIElement {
        if let named {
            return application.windows[named]
        } else {
            return application.windows.element(matching: .window, identifier: "workspace")
        }
    }

    static func getSettingsWindow(_ application: XCUIApplication) -> XCUIElement {
        return application.windows.element(matching: .window, identifier: "settings")
    }

    static func getWelcomeWindow(_ application: XCUIApplication) -> XCUIElement {
        return application.windows.element(matching: .window, identifier: "welcome")
    }

    static func getAboutWindow(_ application: XCUIApplication) -> XCUIElement {
        return application.windows.element(matching: .window, identifier: "about")
    }

    enum Window {
        static func getProjectNavigator(_ window: XCUIElement) -> XCUIElement {
            return window.descendants(matching: .any).matching(identifier: "ProjectNavigator").element
        }

        static func getTabBar(_ window: XCUIElement) -> XCUIElement {
            return window.descendants(matching: .any).matching(identifier: "TabBar").element
        }

        static func getUtilityArea(_ window: XCUIElement) -> XCUIElement {
            return window.descendants(matching: .any).matching(identifier: "UtilityArea").element
        }

        static func getFirstEditor(_ window: XCUIElement) -> XCUIElement {
            return window.descendants(matching: .any)
                .matching(NSPredicate(format: "label CONTAINS[c] 'Text Editor'"))
                .firstMatch
        }
    }

    enum Navigator {
        static func getRows(_ navigator: XCUIElement) -> XCUIElementQuery {
            navigator.descendants(matching: .outlineRow)
        }

        static func getAddButton(_ window: XCUIElement) -> XCUIElement {
            return window.descendants(matching: .any).matching(identifier: "addButton").firstMatch
        }

        static func getSelectedRows(_ navigator: XCUIElement) -> XCUIElementQuery {
            getRows(navigator).matching(NSPredicate(format: "selected = true"))
        }

        static func getProjectNavigatorRows(fileTitle: String, _ navigator: XCUIElement) -> XCUIElementQuery {
            getRows(navigator)
                .containing(.textField, identifier: "ProjectNavigatorTableViewCell-\(fileTitle)")
        }

        static func getProjectNavigatorRow(fileTitle: String, index: Int = 0, _ navigator: XCUIElement) -> XCUIElement {
            return getProjectNavigatorRows(fileTitle: fileTitle, navigator)
                .element(boundBy: index)
        }

        static func waitForProjectNavigatorRow(
            fileTitle: String,
            index: Int = 0,
            _ navigator: XCUIElement,
            timeout: TimeInterval
        ) -> XCUIElement? {
            let deadline = Date().addingTimeInterval(timeout)
            while Date() < deadline {
                let row = getProjectNavigatorRow(fileTitle: fileTitle, index: index, navigator)
                if row.exists {
                    return row
                }
                RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            }

            let row = getProjectNavigatorRow(fileTitle: fileTitle, index: index, navigator)
            return row.exists ? row : nil
        }

        static func getLastProjectNavigatorRow(fileTitle: String, _ navigator: XCUIElement) -> XCUIElement {
            let matchingRows = getProjectNavigatorRows(fileTitle: fileTitle, navigator)
            return matchingRows.element(boundBy: max(matchingRows.count - 1, 0))
        }

        static func disclosureIndicatorForRow(_ row: XCUIElement) -> XCUIElement {
            row.descendants(matching: .disclosureTriangle).firstMatch
        }

        static func rowContainsDisclosureIndicator(_ row: XCUIElement) -> Bool {
            disclosureIndicatorForRow(row).exists
        }

        static func waitForRowCount(
            _ navigator: XCUIElement,
            greaterThan rowCount: Int,
            timeout: TimeInterval
        ) -> Bool {
            waitForRowCount(navigator, timeout: timeout) { $0 > rowCount }
        }

        static func waitForRowCount(
            _ navigator: XCUIElement,
            equalTo rowCount: Int,
            timeout: TimeInterval
        ) -> Bool {
            waitForRowCount(navigator, timeout: timeout) { $0 == rowCount }
        }

        private static func waitForRowCount(
            _ navigator: XCUIElement,
            timeout: TimeInterval,
            predicate: (Int) -> Bool
        ) -> Bool {
            let deadline = Date().addingTimeInterval(timeout)
            while Date() < deadline {
                if predicate(getRows(navigator).count) {
                    return true
                }
                RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            }
            return predicate(getRows(navigator).count)
        }
    }

    enum TabBar {
        static func getTab(labeled title: String, _ tabBar: XCUIElement) -> XCUIElement {
            tabBar.descendants(matching: .group).containing(NSPredicate(format: "value = %@", title)).firstMatch
        }
    }
}
