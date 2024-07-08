//
//  CEActiveTaskTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.07.24.
//

import XCTest
@testable import CodeEdit

final class CEActiveTaskTests: XCTestCase {
    var task: CETask!
    var activeTask: CEActiveTask!

    override func setUpWithError() throws {
        try super.setUpWithError()

        task = CETask(
            name: "Test Task",
            command: "echo $STATE",
            environmentVariables: [CETask.EnvironmentVariable(key: "STATE", value: "Testing")]
        )
        activeTask = CEActiveTask(task: task)
    }

    override func tearDownWithError() throws {
        task = nil
        activeTask = nil
        try super.tearDownWithError()
    }

    func testInitialization() throws {
        XCTAssertEqual(activeTask.task, task, "Active task should be initialized with the provided CETask.")
    }

    func testRunMethod() {
        activeTask.run()
        activeTask.process?.waitUntilExit()

        let testExpectation = XCTestExpectation()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.activeTask.status, .finished)
            XCTAssertTrue(self.activeTask.output.contains("Testing"))
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    // the renew method is needed because a Process can only be run once
    func testRenewMethod() {
        activeTask.run()
        let testExpectation1 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            testExpectation1.fulfill()
        }
        wait(for: [testExpectation1], timeout: 1)

        activeTask.renew()
        activeTask.run()

        let testExpectation2 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.activeTask.status, .finished)
            testExpectation2.fulfill()
        }
        wait(for: [testExpectation2], timeout: 1)
    }

    func testHandleProcessFinished() {
        task.command = "aNon-existentCommand"
        activeTask.run()
        let testExpectation1 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.activeTask.status, .failed)
            testExpectation1.fulfill()
        }
        wait(for: [testExpectation1], timeout: 1)
    }

    func testClearOutput() {
        activeTask.run()
        let testExpectation1 = XCTestExpectation()
        Task {
            await activeTask.clearOutput()
            testExpectation1.fulfill()
        }
        wait(for: [testExpectation1], timeout: 1)
        XCTAssertTrue(activeTask.output.isEmpty)
    }
//    func testClearOutputMethod() async {
//        // Assuming the task generates some output
//        await activeTask.run()
//        XCTAssertFalse(activeTask.output.isEmpty, "Task output should not be empty after task completion.")
//        await activeTask.clearOutput()
//        XCTAssertTrue(activeTask.output.isEmpty, "Task output should be empty after clearOutput is called.")
//    }
}
