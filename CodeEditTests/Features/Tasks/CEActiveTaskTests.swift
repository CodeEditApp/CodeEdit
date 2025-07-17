//
//  CEActiveTaskTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.07.24.
//

import Testing
@testable import CodeEdit

@MainActor
@Suite(.serialized)
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

    @Test(arguments: [Shell.zsh, Shell.bash])
    func testRunMethod(_ shell: Shell) async throws {
        activeTask.run(workspaceURL: nil, shell: shell)
        await waitForExpectation(timeout: .seconds(10)) {
            activeTask.status == .running
        } onTimeout: {
            Issue.record("Task never started. \(activeTask.status)")
        }
        activeTask.waitForExit()

        await waitForExpectation(timeout: .seconds(10)) {
            activeTask.status == .finished
        } onTimeout: {
            Issue.record("Status never changed to finished. \(activeTask.status)")
        }

        let output = try #require(activeTask.output)
        #expect(output.getBufferAsString().contains("Testing"))
    }

    @Test(arguments: [Shell.zsh, Shell.bash])
    func testHandleProcessFinished(_ shell: Shell) async throws {
        task.command = "aNon-existentCommand"
        activeTask.run(workspaceURL: nil, shell: shell)
        activeTask.waitForExit()

        await waitForExpectation(timeout: .seconds(10)) {
            activeTask.status == .failed
        } onTimeout: {
            Issue.record("Status never changed to failed. \(activeTask.status)")
        }
    }

    @Test(arguments: [Shell.zsh, Shell.bash])
    func testClearOutput(_ shell: Shell) async throws {
        activeTask.run(workspaceURL: nil, shell: shell)
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
