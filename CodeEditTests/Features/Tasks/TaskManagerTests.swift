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
    var mockWorkspaceSettings: CEWorkspaceSettingsData!

    override func setUp() {
        super.setUp()

        do {
            let workspaceSettings = try JSONDecoder().decode(CEWorkspaceSettingsData.self, from: Data("{}".utf8))
            mockWorkspaceSettings = workspaceSettings
        } catch {
            XCTFail("Error decoding JSON: \(error.localizedDescription)")
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
            XCTAssertEqual(self.taskManager.taskStatus(taskID: task.id), .running)
            self.taskManager.terminateActiveTask()
            testExpectation1.fulfill()
        }

        wait(for: [testExpectation1], timeout: 1)

        let testExpectation2 = XCTestExpectation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.taskManager.taskStatus(taskID: task.id), .notRunning)
            testExpectation2.fulfill()
        }

        wait(for: [testExpectation2], timeout: 1)
    }

    // This test verifies the functionality of suspending and resuming a task.
    // It ensures that suspend signals do not stack up,
    // meaning only one resume signal is required to resume the task,
    // regardless of the number of times `suspendTask()` is called.
    func testSuspendAndResumeTask() {
        let task = CETask(name: "Test Task", command: "sleep 1")
        mockWorkspaceSettings.tasks.append(task)
        taskManager.selectedTaskID = task.id
        taskManager.executeActiveTask()

        let suspendExpectation = XCTestExpectation(description: "Suspend task after execution")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.taskManager.suspendTask(taskID: task.id)
            suspendExpectation.fulfill()
        }
        wait(for: [suspendExpectation], timeout: 1)

        let verifySuspensionExpectation = XCTestExpectation(description: "Verify task is suspended and resume it")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.taskManager.activeTasks[task.id]?.process?.isRunning, true)
            XCTAssertEqual(self.taskManager.taskStatus(taskID: task.id), .stopped)
            self.taskManager.resumeTask(taskID: task.id)
            verifySuspensionExpectation.fulfill()
        }
        wait(for: [verifySuspensionExpectation], timeout: 1)

        let multipleSuspensionsExpectation = XCTestExpectation(description: "Suspend task multiple times")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.taskManager.taskStatus(taskID: task.id), .running)
            self.taskManager.suspendTask(taskID: task.id)
            self.taskManager.suspendTask(taskID: task.id)
            self.taskManager.suspendTask(taskID: task.id)
            multipleSuspensionsExpectation.fulfill()
        }
        wait(for: [multipleSuspensionsExpectation], timeout: 1)

        let verifySingleResumeExpectation = XCTestExpectation(
            description: "Verify task is suspended and resume it once"
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.taskManager.taskStatus(taskID: task.id), .stopped)
            self.taskManager.resumeTask(taskID: task.id)
            verifySingleResumeExpectation.fulfill()
        }
        wait(for: [verifySingleResumeExpectation], timeout: 1)

        let finalRunningStateExpectation = XCTestExpectation(description: "Verify task is running after single resume")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.taskManager.taskStatus(taskID: task.id), .running)
            finalRunningStateExpectation.fulfill()
        }
        wait(for: [finalRunningStateExpectation], timeout: 1)
    }
}
