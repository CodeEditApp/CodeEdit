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
    var viewModel: SourceControlViewModel!

    // `setUp` and `tearDown` override nonisolated declarations on `XCTestCase`, so they stay
    // nonisolated even though this class is `@MainActor`. XCTest runs both on the main thread for
    // synchronous test cases, so state that here rather than weakening the isolation.
    override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            viewModel = SourceControlViewModel()
        }
    }

    override func tearDown() {
        MainActor.assumeIsolated {
            viewModel = nil
        }
        super.tearDown()
    }

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
