//
//  QuickActionsViewModelTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 02/07/2026.
//

import XCTest
import CodeEditCore
import Factory
@testable import CodeEdit

private final class MockCommandManager: CommandManaging {
    var commands: [Command] = [
        Command(id: "open.drawer", title: "Toggle Utility Area", closureWrapper: {}),
        Command(id: "quick.open", title: "Quick Open", closureWrapper: {}),
        Command(id: "toggle.navigator", title: "Toggle Navigator", closureWrapper: {})
    ]

    func addCommand(name: String, title: String, id: String, command: @escaping () -> Void) {
        commands.append(Command(id: id, title: title, closureWrapper: command))
    }

    func executeCommand(_ id: String) {
        commands.first { $0.id == id }?.closureWrapper()
    }
}

final class QuickActionsViewModelTests: XCTestCase {
    private var viewModel: QuickActionsViewModel!

    override func setUp() {
        super.setUp()
        Container.shared.commandManager.register { MockCommandManager() }
        viewModel = QuickActionsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        Container.shared.commandManager.reset()
        super.tearDown()
    }

    func testFetchMatchingCommandsFiltersCaseInsensitively() {
        viewModel.fetchMatchingCommands(val: "toggle")

        XCTAssertEqual(
            viewModel.filteredCommands.map(\.title).sorted(),
            ["Toggle Navigator", "Toggle Utility Area"]
        )
        XCTAssertEqual(viewModel.selected?.id, viewModel.filteredCommands.first?.id)
    }

    func testFetchMatchingCommandsWithEmptyQueryReturnsAllCommands() {
        viewModel.fetchMatchingCommands(val: "")

        XCTAssertEqual(viewModel.filteredCommands.count, 3)
    }

    func testFetchMatchingCommandsWithoutMatchReturnsNothing() {
        viewModel.fetchMatchingCommands(val: "nonexistent")

        XCTAssertTrue(viewModel.filteredCommands.isEmpty)
        XCTAssertNil(viewModel.selected)
    }

    func testResetClearsQueryAndSelectionAndReseedsCommands() {
        viewModel.fetchMatchingCommands(val: "quick")
        viewModel.commandQuery = "quick"

        viewModel.reset()

        XCTAssertEqual(viewModel.commandQuery, "")
        XCTAssertNil(viewModel.selected)
        XCTAssertEqual(viewModel.filteredCommands.count, 3)
    }
}
