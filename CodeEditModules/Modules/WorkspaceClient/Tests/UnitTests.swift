//
//  UnitTests.swift
//  CodeEdit
//
//  Created by Marco Carnevali on 16/03/22.
//
import Combine
import Foundation
@testable import WorkspaceClient
import XCTest

final class WorkspaceClientUnitTests: XCTestCase {
    let typeOfExtensions = ["json", "txt", "swift", "js", "py", "md"]

    func testListFile() throws {
        let directory = try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
            .appendingPathComponent("CodeEdit", isDirectory: true)
            .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        var cancellable: AnyCancellable?
        let expectation = expectation(description: "wait for files")
        let randomCount = Int.random(in: 1 ... 100)
        let files = generateRandomFiles(amount: randomCount)
        try files.forEach {
            let fakeData = "fake string".data(using: .utf8)
            let fileUrl = directory
                .appendingPathComponent($0)
            try fakeData!.write(to: fileUrl)
        }
        let client: WorkspaceClient = try .default(
            fileManager: .default,
            folderURL: directory,
            ignoredFilesAndFolders: []
        )

        var newFiles: [WorkspaceClient.FileItem] = []

        cancellable = client
            .getFiles
            .sink { files in
                newFiles = files
                expectation.fulfill()
            }

        waitForExpectations(timeout: 0.5)

        XCTAssertEqual(files.count, newFiles.count)
        try FileManager.default.removeItem(at: directory)
        cancellable?.cancel()
    }

    func testDirectoryChanges() throws {
        let directory = try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
            .appendingPathComponent("CodeEdit", isDirectory: true)
            .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        var cancellable: AnyCancellable?
        let expectation = expectation(description: "wait for files")
        expectation.expectedFulfillmentCount = 2

        let randomCount = Int.random(in: 1 ... 100)
        var files = generateRandomFiles(amount: randomCount)
        try files.forEach {
            let fakeData = "fake string".data(using: .utf8)
            let fileUrl = directory
                .appendingPathComponent($0)
            try fakeData!.write(to: fileUrl)
        }

        let client: WorkspaceClient = try .default(
            fileManager: .default,
            folderURL: directory,
            ignoredFilesAndFolders: []
        )

        var newFiles: [WorkspaceClient.FileItem] = []

        cancellable = client
            .getFiles
            .sink { files in
                newFiles = files
                expectation.fulfill()
            }

        let nextBatchOfFiles = generateRandomFiles(amount: 1)
        files.append(contentsOf: nextBatchOfFiles)
        try files.forEach {
            let fakeData = "fake string".data(using: .utf8)
            let fileUrl = directory
                .appendingPathComponent($0)
            try fakeData!.write(to: fileUrl)
        }

        waitForExpectations(timeout: 1.5)

        XCTAssertEqual(files.count, newFiles.count)
        try FileManager.default.removeItem(at: directory)
        cancellable?.cancel()
    }

    func generateRandomFiles(amount: Int) -> [String] {
        [String](repeating: "", count: amount)
            .map { _ in
                let fileName = randomString(length: Int.random(in: 1 ... 100))
                let fileExtension = typeOfExtensions[Int.random(in: 0 ..< typeOfExtensions.count)]
                return "\(fileName).\(fileExtension)"
            }
    }

    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0 ..< length).map { _ in letters.randomElement()! })
    }
}
