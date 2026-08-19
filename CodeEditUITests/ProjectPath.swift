//
//  ProjectPath.swift
//  CodeEditUITests
//
//  Created by Khan Winter on 7/10/24.
//

import Foundation

func projectPath() -> String {
    return String(
        URL(fileURLWithPath: #filePath)
            .pathComponents
            .prefix(while: { $0 != "CodeEditUITests" })
            .joined(separator: "/")
            .dropFirst()
    )
}

private var tempProjectPathIds = Set<String>()
private let codeEditAppBundleID = "app.codeedit.CodeEdit"

private func testRunnerTempProjectURL(id: String) -> URL {
    FileManager.default.temporaryDirectory
        .appending(path: "CodeEditUITests")
        .appending(path: id)
}

private func userHomeDirectoryOutsideSandbox() -> URL {
    let homePath = NSHomeDirectoryForUser(NSUserName()) ?? NSHomeDirectory()
    // UI test runners are sandboxed too; strip that container before addressing the app's container.
    if let containerRange = homePath.range(of: "/Library/Containers/") {
        return URL(fileURLWithPath: String(homePath[..<containerRange.lowerBound]), isDirectory: true)
    }
    return URL(fileURLWithPath: homePath, isDirectory: true)
}

private func appWritableTempProjectURL(id: String) -> URL {
    // CodeEdit is sandboxed, so app-created temporary workspaces live in the app container.
    userHomeDirectoryOutsideSandbox()
        .appending(path: "Library")
        .appending(path: "Containers")
        .appending(path: codeEditAppBundleID)
        .appending(path: "Data")
        .appending(path: "tmp")
        .appending(path: "CodeEditUITests")
        .appending(path: id)
}

private func makeTempID() -> String {
    let id = String((0..<10).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-".randomElement()! })
    if tempProjectPathIds.contains(id) {
        return makeTempID()
    }
    tempProjectPathIds.insert(id)
    return id
}

func tempProjectPath() throws -> String {
    let id = makeTempID()
    let path = testRunnerTempProjectURL(id: id)
    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    return path.path(percentEncoded: false)
}

func appWritableTempProjectID() -> String {
    makeTempID()
}

func appWritableTempProjectPath(id: String) -> String {
    appWritableTempProjectURL(id: id).path(percentEncoded: false)
}

func cleanUpTempProjectPaths() throws {
    let fileManager = FileManager.default
    var cleanupError: Error?
    var remainingIDs = Set<String>()

    for id in tempProjectPathIds {
        let paths = [
            testRunnerTempProjectURL(id: id),
            appWritableTempProjectURL(id: id)
        ]
        var didFailCleanup = false

        for path in paths where fileManager.fileExists(atPath: path.path(percentEncoded: false)) {
            do {
                try fileManager.removeItem(at: path)
            } catch {
                cleanupError = cleanupError ?? error
                didFailCleanup = true
            }
        }

        if didFailCleanup {
            remainingIDs.insert(id)
        }
    }

    tempProjectPathIds = remainingIDs

    if let cleanupError {
        throw cleanupError
    }
}
