//
//  CEActiveTaskTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.07.24.
//

import Testing
@testable import CodeEdit

@MainActor
@Suite
class CEActiveTaskTests {
    var task: CETask
    var activeTask: CEActiveTask

    init() {
        task = CETask(
            name: "Test Task",
            command: "echo $STATE",
            environmentVariables: [CETask.EnvironmentVariable(key: "STATE", value: "Testing")]
        )
        activeTask = CEActiveTask(task: task)
    }

    @Test
    func testInitialization() throws {
        #expect(activeTask.task == task, "Active task should be initialized with the provided CETask.")
    }

    @Test(.timeLimit(.minutes(1)))
    func testRunMethod() async throws {
        activeTask.run(workspaceURL: nil)
        activeTask.waitForExit()

        await waitForExpectation {
            activeTask.status == .finished
        } onTimeout: {
            Issue.record("Status never changed to finished.")
        }

        let output = try #require(activeTask.output)
        #expect(output.getBufferAsString().contains("Testing"))
    }

    @Test(.timeLimit(.minutes(1)))
    func testHandleProcessFinished() async throws {
        task.command = "aNon-existentCommand"
        activeTask.run(workspaceURL: nil)
        activeTask.waitForExit()

        await waitForExpectation {
            activeTask.status == .failed
        } onTimeout: {
            Issue.record("Status never changed to failed.")
        }
    }

    @Test
    func testClearOutput() async throws {
        activeTask.run(workspaceURL: nil)
        activeTask.waitForExit()

        await waitForExpectation {
            activeTask.status == .finished
        } onTimeout: {
            Issue.record("Status never changed to finished.")
        }

        #expect(
            activeTask.output?.getBufferAsString().isEmpty == false,
            "Task output should not be empty after task completion."
        )
        activeTask.clearOutput()

        await waitForExpectation {
            activeTask.output?.getBufferAsString().isEmpty == true
        } onTimeout: {
            Issue.record("Task output should be empty after clearOutput is called.")
        }
    }
}
