//
//  TaskManagerTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.07.24.
//

import Foundation
import Testing
@testable import CodeEdit

@MainActor
@Suite(.serialized)
class TaskManagerTests {
    var taskManager: TaskManager!
    var mockWorkspaceSettings: CEWorkspaceSettingsData!

    init() throws {
        let workspaceSettings = try JSONDecoder().decode(CEWorkspaceSettingsData.self, from: Data("{}".utf8))
        mockWorkspaceSettings = workspaceSettings
        taskManager = TaskManager(workspaceSettings: mockWorkspaceSettings, workspaceURL: nil)
    }

    func testInitialization() {
        #expect(taskManager != nil)
        #expect(taskManager.availableTasks == mockWorkspaceSettings.tasks)
    }

    @Test
    func executeTaskInZsh() async throws {
        Settings.shared.preferences.terminal.shell = .zsh

        let task = CETask(name: "Test Task", command: "echo 'Hello World'")
        mockWorkspaceSettings.tasks.append(task)
        taskManager.selectedTaskID = task.id
        taskManager.executeActiveTask()

        await waitForExpectation(timeout: .seconds(10)) {
            self.taskManager.activeTasks[task.id]?.status == .finished
        } onTimeout: {
            Issue.record("Status never changed to finished.")
        }

        let outputString = try #require(taskManager.activeTasks[task.id]?.output?.getBufferAsString())
        #expect(outputString.contains("Hello World"))
    }

    @Test
    func executeTaskInBash() async throws {
        Settings.shared.preferences.terminal.shell = .bash

        let task = CETask(name: "Test Task", command: "echo 'Hello World'")
        mockWorkspaceSettings.tasks.append(task)
        taskManager.selectedTaskID = task.id
        taskManager.executeActiveTask()

        await waitForExpectation(timeout: .seconds(10)) {
            self.taskManager.activeTasks[task.id]?.status == .finished
        } onTimeout: {
            Issue.record("Status never changed to finished.")
        }

        let outputString = try #require(taskManager.activeTasks[task.id]?.output?.getBufferAsString())
        #expect(outputString.contains("Hello World"))
    }

    @Test(.disabled("Not sure why but tasks run in shells seem to never receive signals."))
    func terminateSelectedTask() async throws {
        let task = CETask(name: "Test Task", command: "sleep 10")
        mockWorkspaceSettings.tasks.append(task)
        taskManager.selectedTaskID = task.id
        taskManager.executeActiveTask()

        await waitForExpectation {
            taskManager.taskStatus(taskID: task.id) == .running
        } onTimeout: {
            Issue.record("Task did not run")
        }

        taskManager.terminateActiveTask()

        await waitForExpectation(timeout: .seconds(10)) {
            taskManager.taskStatus(taskID: task.id) == .notRunning
        } onTimeout: {
            Issue.record("Task did not terminate. \(taskManager.taskStatus(taskID: task.id))")
        }
    }

    // This test verifies the functionality of suspending and resuming a task.
    // It ensures that suspend signals do not stack up,
    // meaning only one resume signal is required to resume the task,
    // regardless of the number of times `suspendTask()` is called.
    @Test(.disabled("Not sure why but tasks run in shells seem to never receive signals."))
    func suspendAndResumeTask() async throws {
        let task = CETask(name: "Test Task", command: "sleep 5")
        mockWorkspaceSettings.tasks.append(task)
        taskManager.selectedTaskID = task.id
        taskManager.executeActiveTask()

        await waitForExpectation {
            taskManager.taskStatus(taskID: task.id) == .running
        } onTimeout: {
            Issue.record("Task did not start running.")
        }
        taskManager.suspendTask(taskID: task.id)

        await waitForExpectation {
            taskManager.taskStatus(taskID: task.id) == .stopped
        } onTimeout: {
            Issue.record("Task did not suspend")
        }
        taskManager.resumeTask(taskID: task.id)

        await waitForExpectation {
            taskManager.taskStatus(taskID: task.id) == .running
        } onTimeout: {
            Issue.record("Task did not resume")
        }

        taskManager.suspendTask(taskID: task.id)
        taskManager.suspendTask(taskID: task.id)
        taskManager.suspendTask(taskID: task.id)

        await waitForExpectation {
            taskManager.taskStatus(taskID: task.id) == .stopped
        } onTimeout: {
            Issue.record("Task did not suspend after multiple suspend messages.")
        }
        taskManager.resumeTask(taskID: task.id)

        await waitForExpectation {
            taskManager.taskStatus(taskID: task.id) == .running
        } onTimeout: {
            Issue.record("Task did not resume after multiple suspend messages.")
        }
    }
}
