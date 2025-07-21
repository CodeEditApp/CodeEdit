//
//  DocumentsUnitTests.swift
//  CodeEditTests
//
//  Created by YAPRYNTSEV Aleksey on 31.12.2022.
//

import XCTest
@testable import CodeEdit

@MainActor
final class DocumentsUnitTests: XCTestCase {
    // Properties
    private var splitViewController: CodeEditSplitViewController!
    private var hapticFeedbackPerformerMock: NSHapticFeedbackPerformerMock!
    private var navigatorViewModel: NavigatorAreaViewModel!
    private var window: NSWindow!
    private var workspace = WorkspaceDocument()

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
        hapticFeedbackPerformerMock = NSHapticFeedbackPerformerMock()
        navigatorViewModel = .init()
        workspace.taskManager = TaskManager(workspaceSettings: CEWorkspaceSettingsData(), workspaceURL: nil)
        window = NSWindow()
        splitViewController = .init(
            workspace: workspace,
            navigatorViewModel: navigatorViewModel,
            windowRef: window,
            hapticPerformer: hapticFeedbackPerformerMock
        )
        splitViewController.viewDidLoad()
    }

    override func tearDown() {
        splitViewController = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testSplitViewHasItems() {
        XCTAssertGreaterThan(splitViewController.splitViewItems.count, 0, "Split controller did not set up correctly.")
    }

    func testSplitViewControllerSnappedWhenWidthInAppropriateRange() {
        for _ in 0..<10 {
            // Given
            let position = CGFloat.random(
                in: (CodeEditSplitViewController.minSnapWidth...CodeEditSplitViewController.maxSnapWidth)
            )

            // When
            let result = splitViewController.splitView(
                splitViewController.splitView,
                constrainSplitPosition: .init(position),
                ofSubviewAt: .zero
            )

            // Then
            XCTAssertEqual(result, CodeEditSplitViewController.snapWidth)
        }
    }

    func testSplitViewControllerStopSnappedWhenWidthIsLowerAppropriateRange() {
        for _ in 0..<10 {
            // Given
            let position = CGFloat.random(in: 0..<(CodeEditSplitViewController.minSidebarWidth / 2))

            // When
            let result = splitViewController.splitView(
                splitViewController.splitView,
                constrainSplitPosition: .init(position),
                ofSubviewAt: .zero
            )

            // Then
            XCTAssertEqual(result, .zero)
        }
    }

    func testSplitViewControllerStopSnappedWhenWidthIsHigherAppropriateRange() {
        for _ in 0..<10 {
            // Given
            let position = CGFloat.random(in: (CodeEditSplitViewController.maxSnapWidth...500))

            // When
            let result = splitViewController.splitView(
                splitViewController.splitView,
                constrainSplitPosition: .init(position),
                ofSubviewAt: .zero
            )

            // Then
            XCTAssertEqual(result, .init(position))
        }
    }

    // Test moving from collapsed to uncollapsed makes a haptic.
    func testSplitViewControllerProducedHapticFeedback() {
        for _ in 0..<10 {
            // Given
            splitViewController.splitViewItems.first?.isCollapsed = true
            let position = CGFloat.random(
                in: (CodeEditSplitViewController.minSidebarWidth / 2)...CodeEditSplitViewController.minSidebarWidth
            )

            // When
            _ = splitViewController.splitView(
                splitViewController.splitView,
                constrainSplitPosition: .init(position),
                ofSubviewAt: .zero
            )

            // Then
            XCTAssertTrue(hapticFeedbackPerformerMock.invokedPerform)
            XCTAssertEqual(hapticFeedbackPerformerMock.invokedPerformCount, 1)
            hapticFeedbackPerformerMock.reset()
        }
    }

    func testSplitViewControllerProducedHapticFeedbackOnceWhenPlentyChangesOccur() {
        for _ in 0..<10 {
            // Given
            splitViewController.splitViewItems.first?.isCollapsed = true
            let firstPosition = CGFloat.random(in: 0..<(CodeEditSplitViewController.minSidebarWidth / 2))
            let secondPosition = CGFloat.random(
                in: (CodeEditSplitViewController.minSidebarWidth / 2)...CodeEditSplitViewController.minSidebarWidth
            )

            // When
            [firstPosition, secondPosition].forEach { position in
                _ = splitViewController.splitView(
                    splitViewController.splitView,
                    constrainSplitPosition: .init(position),
                    ofSubviewAt: .zero
                )
            }

            // Then
            XCTAssertTrue(hapticFeedbackPerformerMock.invokedPerform)
            XCTAssertEqual(hapticFeedbackPerformerMock.invokedPerformCount, 1)
            hapticFeedbackPerformerMock.reset()
        }
    }
}
