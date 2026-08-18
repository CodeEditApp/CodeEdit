//
//  EditorTabReuseTests.swift
//  CodeEditTests
//
//  Created by Boris Serzhanovich on 1/8/26.
//

import Testing
import Foundation
import OrderedCollections
import CodeEditSourceEditor
@testable import CodeEdit

@Suite("Editor tab instance reuse")
struct EditorTabReuseTests {

    @Test
    @MainActor
    func reopeningSameFileReusesEditorInstance() throws {
        try withTempDir { dir in
            let fileURL = dir.appending(path: "Sample.swift")
            try "print(1)\n".write(to: fileURL, atomically: true, encoding: .utf8)
            let file = CEWorkspaceFile(url: fileURL)

            // Disambiguate overloaded `Editor` inits (`OrderedSet<CEWorkspaceFile>` vs `OrderedSet<Tab>`).
            let editor = Editor(files: OrderedSet<CEWorkspaceFile>(), workspace: nil)
            editor.openTab(file: file)

            let firstInstance = try #require(editor.selectedTab)
            firstInstance.cursorPositions = [CursorPosition(line: 3, column: 2)]

            // Re-open the same file (as the navigator / history paths do).
            editor.openTab(file: file)

            let secondInstance = try #require(editor.selectedTab)
            #expect(ObjectIdentifier(firstInstance) == ObjectIdentifier(secondInstance))
            #expect(secondInstance.cursorPositions.first?.start.line == 3)
            #expect(editor.tabs.count == 1)
        }
    }

    @Test
    @MainActor
    func temporaryReopenReusesExistingInstance() throws {
        try withTempDir { dir in
            let fileURL = dir.appending(path: "Temp.swift")
            try "let x = 1\n".write(to: fileURL, atomically: true, encoding: .utf8)
            let file = CEWorkspaceFile(url: fileURL)

            let editor = Editor(files: OrderedSet<CEWorkspaceFile>(), workspace: nil)
            editor.openTab(file: file, asTemporary: true)

            let firstInstance = try #require(editor.selectedTab)
            firstInstance.cursorPositions = [CursorPosition(line: 1, column: 5)]

            editor.openTab(file: file, asTemporary: true)

            let secondInstance = try #require(editor.selectedTab)
            #expect(ObjectIdentifier(firstInstance) == ObjectIdentifier(secondInstance))
            #expect(secondInstance.cursorPositions.first?.start.column == 5)
        }
    }
}
