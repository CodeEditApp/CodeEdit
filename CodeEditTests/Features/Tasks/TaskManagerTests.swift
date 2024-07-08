//
//  TaskManagerTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.07.24.
//

import XCTest
@testable import CodeEdit

final class TaskManagerTests: XCTestCase {
    var taskManager: TaskManager!
    var mockWorkspaceSettings: CEWorkspaceSettings!

    override func setUp() {
        super.setUp()

        if let jsonData = "{}".data(using: .utf8) {
            do {
                let workspaceSettings = try JSONDecoder().decode(CEWorkspaceSettings.self, from: jsonData)
                mockWorkspaceSettings = workspaceSettings
            } catch {
                XCTFail("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        taskManager = TaskManager(workspaceSettings: mockWorkspaceSettings)
    }

    override func tearDown() {
        taskManager = nil
        mockWorkspaceSettings = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(taskManager)
        XCTAssertEqual(taskManager.availableTasks, mockWorkspaceSettings.tasks)
    }

    func testExecuteSelectedTask() {
        let task = CETask(name: "Test Task", command: "echo 'Hello World'")
        mockWorkspaceSettings.tasks.append(task)
        taskManager.selectedTaskID = task.id
        taskManager.executeActiveTask()

        let testExpectation = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertTrue(((self.taskManager.activeTasks[task.id]?.output.contains("Hello World")) != nil))
            testExpectation.fulfill()
        }
        wait(for: [testExpectation], timeout: 1)
    }

    func testTerminateSelectedTask() {
        let task = CETask(name: "Test Task", command: "sleep 1")
        mockWorkspaceSettings.tasks.append(task)
        taskManager.selectedTaskID = task.id
        taskManager.executeActiveTask()

        let testExpectation1 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.taskManager.taskStatus(task.id), .running)
            self.taskManager.terminateActiveTask()
            testExpectation1.fulfill()
        }

        wait(for: [testExpectation1], timeout: 1)

        let testExpectation2 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.taskManager.taskStatus(task.id), .failed)
            testExpectation2.fulfill()
        }

        wait(for: [testExpectation2], timeout: 1)
    }

    // Additional tests for suspend, resume, terminate, stopAllTasks, and taskStatus would follow a similar structure
    // They would require mocking or stubbing the behavior of CEActiveTask and possibly the Process class
}
