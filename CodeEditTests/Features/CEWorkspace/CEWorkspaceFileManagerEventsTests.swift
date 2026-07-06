//
//  CEWorkspaceFileManagerEventsTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

import XCTest
import CodeEditCore
@testable import CodeEdit

final class CEWorkspaceFileManagerEventsTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appending(path: "CEWSFMEvents-\(UUID().uuidString)", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("x".utf8).write(to: directory.appending(path: "changed.swift"))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    func testAppliesGitStatusChangedEvent() throws {
        let bus = EventBus()
        let fm = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            eventBus: bus,
            sourceControlManager: nil
        )
        let key = directory.appending(path: "changed.swift").relativePath
        XCTAssertNotNil(fm.getFile(key), "file should be cached after init")

        bus.publish(GitStatusChangedEvent(workspaceURL: directory, changed: [key: .modified]))

        let expectation = expectation(description: "status applied")
        DispatchQueue.main.async {
            XCTAssertEqual(fm.getFile(key)?.gitStatus, .modified)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    func testClearsStaleGitStatus() throws {
        let bus = EventBus()
        let fm = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            eventBus: bus,
            sourceControlManager: nil
        )
        let key = directory.appending(path: "changed.swift").relativePath
        fm.getFile(key)?.gitStatus = .modified

        bus.publish(GitStatusChangedEvent(workspaceURL: directory, changed: [:]))

        let expectation = expectation(description: "status cleared")
        DispatchQueue.main.async {
            XCTAssertNil(fm.getFile(key)?.gitStatus)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }

    func testIgnoresEventsForOtherWorkspaces() throws {
        let bus = EventBus()
        let fm = CEWorkspaceFileManager(
            folderUrl: directory,
            ignoredFilesAndFolders: [],
            eventBus: bus,
            sourceControlManager: nil
        )
        let key = directory.appending(path: "changed.swift").relativePath

        bus.publish(GitStatusChangedEvent(workspaceURL: URL(filePath: "/tmp/other"), changed: [key: .modified]))

        let expectation = expectation(description: "no apply")
        DispatchQueue.main.async {
            XCTAssertNil(fm.getFile(key)?.gitStatus)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }
}
