//
//  WorkspaceEventsTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

import XCTest
import CodeEditCore

final class WorkspaceEventsTests: XCTestCase {
    func testWorkspaceFileEventCarriesKindAndURL() {
        let url = URL(filePath: "/tmp/ws")
        let event = WorkspaceFileEvent(workspaceURL: url, kind: .filesystemChanged(paths: ["a.swift"]))
        XCTAssertEqual(event.workspaceURL, url)
        if case let .filesystemChanged(paths) = event.kind {
            XCTAssertEqual(paths, ["a.swift"])
        } else {
            XCTFail("wrong kind")
        }
    }

    func testGitStatusChangedEventCarriesMap() {
        let url = URL(filePath: "/tmp/ws")
        let event = GitStatusChangedEvent(workspaceURL: url, changed: ["a.swift": .modified])
        XCTAssertEqual(event.workspaceURL, url)
        XCTAssertEqual(event.changed["a.swift"], .modified)
    }
}
