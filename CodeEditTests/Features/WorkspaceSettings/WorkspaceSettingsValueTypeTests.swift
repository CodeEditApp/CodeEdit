//
//  WorkspaceSettingsValueTypeTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 05/07/2026.
//

import XCTest
import CodeEditCore

final class WorkspaceSettingsValueTypeTests: XCTestCase {

    // MARK: - CETask computed properties

    func testFullCommandWithoutWorkingDirectory() {
        let task = CETask(name: "Build", command: "swift build")
        XCTAssertEqual(task.fullCommand, "swift build")
    }

    func testFullCommandWithWorkingDirectory() {
        let task = CETask(workingDirectory: "/tmp/my project", command: "swift build")
        XCTAssertEqual(task.fullCommand, #"cd "/tmp/my project" && swift build"#)
    }

    func testEnvironmentVariablesDictionary() {
        let task = CETask(
            command: "run",
            environmentVariables: [
                .init(key: "A", value: "1"),
                .init(key: "B", value: "2")
            ]
        )
        XCTAssertEqual(task.environmentVariablesDictionary, ["A": "1", "B": "2"])
    }

    func testIsInvalid() {
        XCTAssertTrue(CETask(name: "", command: "x").isInvalid)
        XCTAssertTrue(CETask(name: "x", command: "").isInvalid)
        XCTAssertFalse(CETask(name: "x", command: "y").isInvalid)
    }

    // MARK: - Codable round-trips (on-disk contract)

    func testCETaskRoundTripPreservesFields() throws {
        let task = CETask(
            name: "Build",
            target: "SSH",
            workingDirectory: "/tmp",
            command: "swift build",
            environmentVariables: [.init(key: "K", value: "V")]
        )
        let data = try JSONEncoder().encode(task)
        let decoded = try JSONDecoder().decode(CETask.self, from: data)

        XCTAssertEqual(decoded.name, "Build")
        XCTAssertEqual(decoded.target, "SSH")
        XCTAssertEqual(decoded.workingDirectory, "/tmp")
        XCTAssertEqual(decoded.command, "swift build")
        XCTAssertEqual(decoded.environmentVariablesDictionary, ["K": "V"])
    }

    func testCETaskOmitsDefaultTargetAndEmptyFields() throws {
        let task = CETask(name: "Build", target: "My Mac", command: "swift build")
        let json = String(data: try JSONEncoder().encode(task), encoding: .utf8) ?? ""
        // "My Mac" is the implicit default and must not be written; empty workingDirectory omitted.
        XCTAssertFalse(json.contains("My Mac"))
        XCTAssertFalse(json.contains("workingDirectory"))
        XCTAssertTrue(json.contains("swift build"))
    }

    func testSettingsDataDefaultsMissingKeys() throws {
        let decoded = try JSONDecoder().decode(CEWorkspaceSettingsData.self, from: Data("{}".utf8))
        XCTAssertTrue(decoded.isEmpty())
        XCTAssertEqual(decoded.tasks.count, 0)
        XCTAssertEqual(decoded.project.projectName, "")
    }

    func testSettingsDataIsEmpty() {
        XCTAssertTrue(CEWorkspaceSettingsData().isEmpty())
        var withName = CEWorkspaceSettingsData()
        withName.project.projectName = "MyProject"
        XCTAssertFalse(withName.isEmpty())
        var withTask = CEWorkspaceSettingsData()
        withTask.tasks.append(CETask(name: "t", command: "c"))
        XCTAssertFalse(withTask.isEmpty())
    }

    func testEmptySettingsEncodeToEmptyObject() throws {
        let json = String(data: try JSONEncoder().encode(CEWorkspaceSettingsData()), encoding: .utf8) ?? ""
        XCTAssertEqual(json, "{}")
    }
}
