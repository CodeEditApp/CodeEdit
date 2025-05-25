//
//  ShellTests.swift
//  CodeEditTests
//
//  Created by Tommy Ludwig on 08.07.24.
//

import XCTest
@testable import CodeEdit

final class ShellTests: XCTestCase {
    var process: Process!
    var outputPipe: Pipe!

    override func setUp() {
        super.setUp()
        process = Process()
        outputPipe = Pipe()
    }

    override func tearDown() {
        process = nil
        outputPipe = nil
        super.tearDown()
    }

    func testExecuteCommandWithShellInitialization() throws {
        let command = "echo $STATE"
        let environmentVariables = ["STATE": "Testing"]
        let shell: Shell = .bash

        XCTAssertNoThrow(try Shell.executeCommandWithShell(
            process: process,
            command: command,
            environmentVariables: environmentVariables,
            shell: shell,
            outputPipe: outputPipe
        ))

        XCTAssertEqual(process.executableURL, URL(fileURLWithPath: shell.url))
        XCTAssertEqual(process.environment, environmentVariables)
        XCTAssertEqual(process.arguments, ["--login", "-c", command])
        XCTAssertNotNil(process.standardOutput)
        XCTAssertNotNil(process.standardError)

        // Additional assertion to check output
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = try XCTUnwrap(
            String(bytes: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        XCTAssertTrue(outputString.contains("Testing"))
    }

    func testExecuteCommandWithShellOutput() throws {
        let command = "echo $STATE"
        let environmentVariables = ["STATE": "Testing"]
        let shell: Shell = .bash

        XCTAssertNoThrow(try Shell.executeCommandWithShell(
            process: process,
            command: command,
            environmentVariables: environmentVariables,
            shell: shell,
            outputPipe: outputPipe
        ))

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputString = try XCTUnwrap(
            String(bytes: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        XCTAssertTrue(outputString.contains("Testing"))
    }

    func testExecuteCommandWithExecutableOverrideAttempt() {
        let command = "echo 'Hello, World!'"
        let shell: Shell = .bash

        // Intentionally providing an invalid shell path to try trigger an error
        process.executableURL = URL(fileURLWithPath: "/invalid/path")

        XCTAssertNoThrow(try Shell.executeCommandWithShell(
            process: process,
            command: command,
            shell: shell,
            outputPipe: outputPipe
        ))
    }
}
