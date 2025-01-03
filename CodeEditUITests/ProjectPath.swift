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

private func makeTempID() -> String {
    let id = String((0..<10).map { _ in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-".randomElement()! })
    if tempProjectPathIds.contains(id) {
        return makeTempID()
    }
    tempProjectPathIds.insert(id)
    return id
}

func tempProjectPath() throws -> String {
    let baseDir = FileManager.default.temporaryDirectory.appending(path: "CodeEditUITests")
    let id = makeTempID()
    let path = baseDir.appending(path: id)
    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    return path.path(percentEncoded: false)
}

func cleanUpTempProjectPaths() throws {
    let baseDir = FileManager.default.temporaryDirectory.appending(path: "CodeEditUITests")
    try FileManager.default.removeItem(at: baseDir)
    tempProjectPathIds.removeAll()
}
