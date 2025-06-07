//
//  HiderInterfaceTests.swift
//  CodeEditUITests
//
//  Created by Simon Kudsk on 14/05/2025.
//

import XCTest
final class HideInterfaceUITests: XCTestCase {

    // MARK: – Setup
    private var app: XCUIApplication!
    private var path: String!

    override func setUp() async throws {
        try await MainActor.run {
            (app, path) = try App.launchWithTempDir()
        }
    }

    /// List of the  panels to test with
    private let allPanels: () -> [String] = {
        ["Navigator", "Inspector", "Utility Area", "Toolbar"]
    }

    // MARK: – Tests

    /// Test 1: Ensure each panel can show and hide individually.
    func testPanelsShowAndHideIndividually() {
        let viewMenu = app.menuBars.menuBarItems["View"]
        for panel in allPanels() {
            // Show panel
            let showItem = "Show \(panel)"
            if viewMenu.menuItems[showItem].exists {
                viewMenu.menuItems[showItem].click()
            }

            // Verify panel is visible
            viewMenu.click()
            XCTAssertTrue(viewMenu.menuItems["Hide \(panel)"].exists, "\(panel) should be visible after show")

            // Hide panel and verify it being hidden
            viewMenu.menuItems[("Hide \(panel)")].click()
            viewMenu.click()
            XCTAssertTrue(viewMenu.menuItems["Show \(panel)"].exists, "\(panel) should be hidden after hide")
        }
    }

    /// Test 2: Hide interface hides all panels.
    func testHideInterfaceHidesAllPanels() {
        let viewMenu = app.menuBars.menuBarItems["View"]
        // Ensure all panels are shown
        for panel in allPanels() {
            let showItem = "Show \(panel)"
            if viewMenu.menuItems[showItem].exists {
                viewMenu.menuItems[showItem].click()
            }
        }

        // Hide interface
        viewMenu.menuItems[("Hide Interface")].click()

        // Verify all panels are hidden
        viewMenu.click()
        for panel in allPanels() {
            XCTAssertTrue(viewMenu.menuItems["Show \(panel)"].exists, "\(panel) should be hidden")
        }
    }

    /// Test 3: Show interface shows all panels when none are visible.
    func testShowInterfaceShowsAllWhenNoneVisible() {
        let viewMenu = app.menuBars.menuBarItems["View"]
        // Ensure all panels are hidden
        for panel in allPanels() {
            let hideItem = "Hide \(panel)"
            if viewMenu.menuItems[hideItem].exists {
                viewMenu.menuItems[hideItem].click()
            }
        }

        // Verify button says Show Interface
        viewMenu.click()
        XCTAssertTrue(viewMenu.menuItems["Show Interface"].exists, "Interface button should say Show Interface")

        // Show interface without waiting
        viewMenu.menuItems[("Show Interface")].click()

        // Verify all panels are shown
        viewMenu.click()
        for panel in allPanels() {
            XCTAssertTrue(
                viewMenu.menuItems["Hide \(panel)"].exists,
                "\(panel) should be visible after showing interface"
            )
        }
    }

    /// Test 4: Show interface restores previous panel state.
    func testShowInterfaceRestoresPreviousState() {
        let viewMenu = app.menuBars.menuBarItems["View"]
        let initialOpen = ["Navigator", "Toolbar"]

        // Set initial state
        for panel in allPanels() {
            let item = initialOpen.contains(panel) ? "Show \(panel)" : "Hide \(panel)"
            if viewMenu.menuItems[item].exists {
                viewMenu.menuItems[item].click()
            }
        }

        // Hide then show interface
        viewMenu.menuItems[("Hide Interface")].click()
        viewMenu.menuItems[("Show Interface")].click()

        // Verify only initial panels are shown
        viewMenu.click()
        for panel in allPanels() {
            let shouldBeVisible = initialOpen.contains(panel)
            XCTAssertEqual(viewMenu.menuItems["Hide \(panel)"].exists, shouldBeVisible, "\(panel) visibility mismatch")
        }
    }

    /// Test 5: Individual toggles after hide update the interface button.
    func testIndividualTogglesUpdateInterfaceButton() {
        let viewMenu = app.menuBars.menuBarItems["View"]
        let initialOpen = ["Navigator", "Toolbar"]

        // Set initial visibility
        for panel in allPanels() {
            let item = initialOpen.contains(panel) ? "Show \(panel)" : "Hide \(panel)"
            if viewMenu.menuItems[item].exists {
                viewMenu.menuItems[item].click()
            }
        }

        // Hide interface
        viewMenu.menuItems[("Hide Interface")].click()

        // Individually enable initial panels
        for panel in initialOpen {
            viewMenu.menuItems[("Show \(panel)")].click()
        }

        // Verify interface button resets to Hide Interface
        viewMenu.click()
        XCTAssertTrue(
            viewMenu.menuItems["Hide Interface"].exists,
            "Interface should say hide interface when all previous panels are enabled again"
        )
    }

    /// Test 6: Partial show after hide restores correct panels.
    func testPartialShowAfterHideRestoresCorrectPanels() {
        let viewMenu = app.menuBars.menuBarItems["View"]
        let initialOpen = ["Navigator", "Toolbar"]

        // Set initial visibility
        for panel in allPanels() {
            let item = initialOpen.contains(panel) ? "Show \(panel)" : "Hide \(panel)"
            if viewMenu.menuItems[item].exists {
                viewMenu.menuItems[item].click()
            }
        }

        // Hide interface
        viewMenu.menuItems[("Hide Interface")].click()

        // Individually enable navigator and inspector
        for panel in ["Navigator", "Inspector"] {
            viewMenu.menuItems[("Show \(panel)")].click()
        }
        // Show interface
        viewMenu.menuItems[("Show Interface")].click()

        // Verify correct panels are shown
        viewMenu.click()
        for panel in ["Navigator", "Inspector", "Toolbar"] {
            XCTAssertTrue(viewMenu.menuItems["Hide \(panel)"].exists, "\(panel) should be visible")
        }

        // Utility Area should remain hidden
        XCTAssertTrue(viewMenu.menuItems["Show Utility Area"].exists, "Utility Area should be hidden")
    }
}
