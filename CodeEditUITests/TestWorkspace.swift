//
//  TestWorkspace.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 1/8/24.
//

import Foundation

enum TestWorkspace {
    private static func getDirectory() throws -> URL {
        try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("CodeEdit", isDirectory: true)
        .appendingPathComponent("UITestWorkspace", isDirectory: true)
    }

    /// Set up a test workspace environment.
    /// - Returns: The root URL of the workspace.
    static func setUp() throws -> URL {
        let directory = try getDirectory()
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        // Create test files in directory
        try String("Hello World").write(to: directory.appending(path: "file.txt"), atomically: true, encoding: .utf8)

        let subDirectory = directory.appending(path: "Directory")
        try FileManager.default.createDirectory(at: subDirectory, withIntermediateDirectories: true)

        try String("func helloWorld() {\n    print(\"Hello World\")\n}")
            .write(to: subDirectory.appending(path: "TestSwiftFile.swift"), atomically: true, encoding: .utf8)
        try String("function helloWorld() {\n    console.log(\"Hello World\");\n}")
            .write(to: subDirectory.appending(path: "TestJSFile.js"), atomically: true, encoding: .utf8)

        return directory
    }

    static func tearDown() throws {
        let directory = try getDirectory()
        try FileManager.default.removeItem(at: directory)
    }
}
