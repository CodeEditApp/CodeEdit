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
    var directory: URL!

    class DummyObserver: CEWorkspaceFileManagerObserver {
        var completion: (() -> Void)?

        init(completion: @escaping () -> Void) {
            self.completion = completion
        }

        func fileManagerUpdated() {
            completion?()
        }
    }

    override func setUp() async throws {
        directory = try FileManager.default.url(
            for: .developerApplicationDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("CodeEdit", isDirectory: true)
        .appendingPathComponent("WorkspaceClientTests", isDirectory: true)
        try? FileManager.default.removeItem(at: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: directory)
    }

    func testListFile() throws {
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

        // Compare to flattened files - 1 cause root is in there
        XCTAssertEqual(files.count, client.flattenedFileItems.count - 1)
        try FileManager.default.removeItem(at: directory)
    }

    func testDirectoryChanges() throws {
        let client = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: []
        )

        let newFile = generateRandomFiles(amount: 1)[0]
        let expectation = XCTestExpectation(description: "wait for files")

        let observer = DummyObserver {
            let url = client.folderUrl.appending(path: newFile).path
            if client.flattenedFileItems[url] != nil {
                expectation.fulfill()
            }
        }
        client.addObserver(observer)

        var files = client.flattenedFileItems.map { $0.value.name }
        files.append(newFile)
        try files.forEach {
            let fakeData = "fake string".data(using: .utf8)
            let fileUrl = directory
                .appendingPathComponent($0)
            try fakeData!.write(to: fileUrl)
        }

        wait(for: [expectation])
        XCTAssertEqual(files.count, client.flattenedFileItems.count - 1)
        try FileManager.default.removeItem(at: directory)
        client.removeObserver(observer)
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
