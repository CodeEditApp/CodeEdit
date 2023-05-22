//
//  UnitTests.swift
//  CodeEditModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//
import Combine
import Foundation
import XCTest
@testable import CodeEdit

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
        let client = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: []
        )

        var newFiles: [CEWorkspaceFile] = []

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
        let expectation = XCTestExpectation(description: "wait for files")

        let randomCount = Int.random(in: 1 ... 100)
        var files = generateRandomFiles(amount: randomCount)
        try files.forEach {
            let fakeData = "fake string".data(using: .utf8)
            let fileUrl = directory
                .appendingPathComponent($0)
            try fakeData!.write(to: fileUrl)
        }

        let client = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: []
        )

        var newFiles: [CEWorkspaceFile] = []

        cancellable = client
            .getFiles
            .sink { files in
                newFiles = files
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 0.5)

        let nextBatchOfFiles = generateRandomFiles(amount: 1)
        files.append(contentsOf: nextBatchOfFiles)
        try files.forEach {
            let fakeData = "fake string".data(using: .utf8)
            let fileUrl = directory
                .appendingPathComponent($0)
            try fakeData!.write(to: fileUrl)
        }

        XCTAssertEqual(files.count, newFiles.count + 1)
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
