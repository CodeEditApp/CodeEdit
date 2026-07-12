//
//  GitRefreshActionsTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 06/07/2026.
//

@testable import CESourceControl
import XCTest
@testable import CodeEdit

final class GitRefreshActionsTests: XCTestCase {
    private let root = "MyWorkspace"

    private typealias Action = SourceControlManager.GitRefreshAction

    private func actions(_ paths: [String]) -> Set<Action> {
        SourceControlManager.gitRefreshActions(for: paths, workspaceRelativePath: root)
    }

    func testNonGitChangeRefreshesChangedFiles() {
        XCTAssertTrue(actions(["MyWorkspace/Sources/App.swift"]).contains(.changedFiles))
    }

    func testIndexChangeRefreshesChangedFiles() {
        XCTAssertTrue(actions(["MyWorkspace/.git/index"]).contains(.changedFiles))
    }

    func testPureGitInternalChangeDoesNotRefreshChangedFiles() {
        XCTAssertFalse(actions(["MyWorkspace/.git/logs/HEAD"]).contains(.changedFiles))
    }

    func testStashRefRefreshesStash() {
        XCTAssertTrue(actions(["MyWorkspace/.git/refs/stash"]).contains(.stash))
    }

    func testHeadsRefreshesBranches() {
        XCTAssertTrue(actions(["MyWorkspace/.git/refs/heads/main"]).contains(.branches))
    }

    func testHeadRefreshesCurrentBranch() {
        XCTAssertTrue(actions(["MyWorkspace/.git/HEAD"]).contains(.currentBranch))
    }

    func testConfigRefreshesRemotes() {
        XCTAssertTrue(actions(["MyWorkspace/.git/config"]).contains(.remotes))
    }

    func testGitFolderRefreshesValidate() {
        XCTAssertTrue(actions(["MyWorkspace/.git"]).contains(.validate))
    }
}
