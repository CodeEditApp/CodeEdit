//
//  WorkspaceLifecycleTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 13/07/2026.
//

import XCTest
import CEEditor
import CETerminal
@testable import CodeEdit

@MainActor
final class WorkspaceLifecycleTests: XCTestCase {
    /// tearDown() no longer nils members; this guards that nothing retains the
    /// workspace graph after close (a strong manager→Workspace back-reference,
    /// or a manager self-cycle via a `sink` without `[weak self]`).
    func testWorkspaceAndManagersDeallocateAfterTearDown() throws {
        weak var weakWorkspace: Workspace?
        weak var weakEditorManager: EditorManager?
        weak var weakTaskManager: TaskManager?

        try autoreleasepool {
            let workspace = try TestWorkspaceFactory.make()
            weakWorkspace = workspace
            weakEditorManager = workspace.editorManager
            weakTaskManager = workspace.taskManager
            workspace.tearDown()
        }

        XCTAssertNil(weakWorkspace, "Workspace leaked after tearDown")
        XCTAssertNil(weakEditorManager, "EditorManager leaked after tearDown")
        XCTAssertNil(weakTaskManager, "TaskManager leaked after tearDown")
    }
}
