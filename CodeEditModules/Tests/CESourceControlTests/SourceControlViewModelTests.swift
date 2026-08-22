//
//  SourceControlViewModelTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 02/07/2026.
//

@testable import CESourceControl
import XCTest

@MainActor
final class SourceControlViewModelTests: XCTestCase {
    /// Built lazily rather than in `setUp`, which overrides a nonisolated `XCTestCase` method and so
    /// cannot touch this `@MainActor` class's state. XCTest creates a fresh test-case instance per
    /// test method, so each test still gets its own view model.
    private lazy var viewModel = SourceControlViewModel()

    // MARK: - Operation field reset

    func testPushSheetPresentedResetsOperationFields() {
        viewModel.operationRebase = true
        viewModel.operationForce = true
        viewModel.operationIncludeTags = true

        viewModel.pushSheetIsPresented = true

        XCTAssertNil(viewModel.operationBranch)
        XCTAssertNil(viewModel.operationRemote)
        XCTAssertFalse(viewModel.operationRebase)
        XCTAssertFalse(viewModel.operationForce)
        XCTAssertFalse(viewModel.operationIncludeTags)
    }

    func testPullSheetPresentedResetsOperationFields() {
        viewModel.operationRebase = true
        viewModel.operationForce = true
        viewModel.operationIncludeTags = true

        viewModel.pullSheetIsPresented = true

        XCTAssertNil(viewModel.operationBranch)
        XCTAssertNil(viewModel.operationRemote)
        XCTAssertFalse(viewModel.operationRebase)
        XCTAssertFalse(viewModel.operationForce)
        XCTAssertFalse(viewModel.operationIncludeTags)
    }

    // MARK: - Sheet independence

    func testSheetBooleansAreIndependent() {
        viewModel.pushSheetIsPresented = true

        XCTAssertFalse(viewModel.pullSheetIsPresented)
        XCTAssertFalse(viewModel.fetchSheetIsPresented)
        XCTAssertFalse(viewModel.stashSheetIsPresented)
        XCTAssertFalse(viewModel.addExistingRemoteSheetIsPresented)
    }

    // MARK: - Alert independence

    func testAlertBooleansAreIndependent() {
        viewModel.discardAllAlertIsPresented = true

        XCTAssertFalse(viewModel.noChangesToStageAlertIsPresented)
        XCTAssertFalse(viewModel.noChangesToUnstageAlertIsPresented)
        XCTAssertFalse(viewModel.noChangesToStashAlertIsPresented)
        XCTAssertFalse(viewModel.noChangesToDiscardAlertIsPresented)
    }
}
