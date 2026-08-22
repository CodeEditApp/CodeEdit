//
//  ProjectNavigatorViewModelTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 03/07/2026.
//

import XCTest
@testable import CodeEdit

@MainActor
final class ProjectNavigatorViewModelTests: XCTestCase {
    var viewModel: ProjectNavigatorViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ProjectNavigatorViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testDefaults() {
        XCTAssertEqual(viewModel.navigatorFilter, "")
        XCTAssertTrue(viewModel.sortFoldersOnTop)
        XCTAssertFalse(viewModel.sourceControlFilter)
    }

    func testFilterMutationPublishes() {
        let expectation = expectation(description: "objectWillChange fires")
        let cancellable = viewModel.objectWillChange.sink { expectation.fulfill() }
        viewModel.navigatorFilter = "abc"
        wait(for: [expectation], timeout: 1)
        cancellable.cancel()
        XCTAssertEqual(viewModel.navigatorFilter, "abc")
    }
}
