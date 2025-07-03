//
//  UndoManagerRegistrationTests.swift
//  CodeEditTests
//
//  Created by Khan Winter on 7/3/25.
//

@testable import CodeEdit
import Testing
import Foundation
import CodeEditTextView

@MainActor
@Suite
struct UndoManagerRegistrationTests {
    let registrar = UndoManagerRegistration()
    let file = CEWorkspaceFile(url: URL(filePath: "/fake/dir/file.txt"))
    let textView = TextView(string: "hello world")

    @Test
    func newUndoManager() {
        let manager = registrar.manager(forFile: file)
        #expect(manager.canUndo == false)
    }

    @Test
    func undoManagersRetained() throws {
        let manager = registrar.manager(forFile: file)
        textView.setUndoManager(manager)
        manager.registerMutation(.init(insert: "hello", at: 0, limit: 11))

        let sameManager = registrar.manager(forFile: file)
        #expect(manager === sameManager)
        #expect(sameManager.canUndo)
    }
}
