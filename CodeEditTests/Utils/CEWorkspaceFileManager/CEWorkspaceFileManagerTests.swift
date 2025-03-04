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

final class CEWorkspaceFileManagerUnitTests: XCTestCase {
    let typeOfExtensions = ["json", "txt", "swift", "js", "py", "md"]
    var directory: URL!

    class DummyObserver: CEWorkspaceFileManagerObserver {
        var completion: (() -> Void)?

        init(completion: @escaping () -> Void) {
            self.completion = completion
        }

        func fileManagerUpdated(updatedItems: Set<CEWorkspaceFile>) {
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
        .appending(path: "CodeEdit", directoryHint: .isDirectory)
        .appending(path: "WorkspaceClientTests", directoryHint: .isDirectory)
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
            let fakeData = Data("fake string".utf8)
            let fileUrl = directory
                .appending(path: $0)
            try fakeData.write(to: fileUrl)
        }
        let client = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            sourceControlManager: nil
        )

        // Compare to flattened files - 1 cause root is in there
        XCTAssertEqual(files.count, client.flattenedFileItems.count - 1)
        try FileManager.default.removeItem(at: directory)
    }

    func testDirectoryChanges() throws {
        let client = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            sourceControlManager: nil
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
            let fakeData = Data("fake string".utf8)
            let fileUrl = directory
                .appending(path: $0)
            try fakeData.write(to: fileUrl)
        }

        wait(for: [expectation], timeout: 2.0)
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

    func testGetFile() throws {
        let testDirectoryURL = directory.appending(path: "level1/level-2/level3")
        let testFileURL = directory.appending(path: "level1/level-2/level3/file.txt")
        try FileManager.default.createDirectory(at: testDirectoryURL, withIntermediateDirectories: true)
        try "".write(to: testFileURL, atomically: true, encoding: .utf8)

        let fileManager = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            sourceControlManager: nil
        )

        XCTAssert(fileManager.getFile(testFileURL.path()) == nil)
        XCTAssert(fileManager.childrenOfFile(CEWorkspaceFile(url: testFileURL)) == nil)
        XCTAssert(fileManager.getFile(testFileURL.path(), createIfNotFound: true) != nil)
        XCTAssert(fileManager.childrenOfFile(CEWorkspaceFile(url: testDirectoryURL)) != nil)
    }

    func testDeleteFile() throws {
        let testFileURL = directory.appending(path: "file.txt")
        try "".write(to: testFileURL, atomically: true, encoding: .utf8)

        let fileManager = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            sourceControlManager: nil
        )
        XCTAssert(fileManager.getFile(testFileURL.path()) != nil)
        XCTAssert(FileManager.default.fileExists(atPath: testFileURL.path()) == true)
        try fileManager.delete(file: CEWorkspaceFile(url: testFileURL), confirmDelete: false)
        XCTAssert(FileManager.default.fileExists(atPath: testFileURL.path()) == false)
    }

    func testDuplicateFile() throws {
        let testFileURL = directory.appending(path: "file.txt")
        let testDuplicatedFileURL = directory.appending(path: "file copy.txt")
        try "😄".write(to: testFileURL, atomically: true, encoding: .utf8)

        let fileManager = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            sourceControlManager: nil
        )
        XCTAssert(fileManager.getFile(testFileURL.path()) != nil)
        XCTAssert(FileManager.default.fileExists(atPath: testFileURL.path()) == true)
        try fileManager.duplicate(file: CEWorkspaceFile(url: testFileURL))
        XCTAssert(FileManager.default.fileExists(atPath: testFileURL.path()) == true)
        XCTAssert(FileManager.default.fileExists(atPath: testDuplicatedFileURL.path(percentEncoded: false)) == true)
        XCTAssert(try String(contentsOf: testDuplicatedFileURL) == "😄")
    }

    func testAddFile() throws {
        let fileManager = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            sourceControlManager: nil
        )

        // This will throw if unsuccessful.
        var file = try fileManager.addFile(fileName: "Test File.txt", toFile: fileManager.workspaceItem)

        // Should not add a new file extension, it already has one. This adds a '.' at the end if incorrect.
        // See #1966
        XCTAssertEqual(file.name, "Test File.txt")

        // Test the automatic file extension stuff
        file = try fileManager.addFile(
            fileName: "Test File Extension",
            toFile: fileManager.workspaceItem,
            useExtension: nil
        )

        // Should detect '.txt' with the previous file in the same directory.
        XCTAssertEqual(file.name, "Test File Extension.txt")

        // Test explicit file extension with both . and no period at the beginning of the given extension.
        file = try fileManager.addFile(
            fileName: "Explicit File Extension",
            toFile: fileManager.workspaceItem,
            useExtension: "xlsx"
        )
        XCTAssertEqual(file.name, "Explicit File Extension.xlsx")
        file = try fileManager.addFile(
            fileName: "PDF",
            toFile: fileManager.workspaceItem,
            useExtension: ".pdf"
        )
        XCTAssertEqual(file.name, "PDF.pdf")
    }
}
