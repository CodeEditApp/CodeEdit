//
//  AppActiveCursorStateTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Combine
import Testing
import CodeEditCore
import CEWorkspaceFileManager
import CodeEditSourceEditor
@testable import CodeEdit

@Suite
struct AppActiveCursorStateTests {
    @MainActor
    @Test
    func reflectsAndPublishesActiveTabCursorPositions() {
        let editorManager = EditorManager()
        let fileA = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/a.swift"))
        editorManager.activeEditor.openTab(file: fileA)

        let state = AppActiveCursorState(editorManager: editorManager)

        // The freshly opened tab seeds a default cursor at line 1, column 1.
        #expect(state.cursorPositions.first?.line == 1)
        #expect(state.cursorPositions.first?.column == 1)

        var received: [[EditorCursorPosition]] = []
        let cancellable = state.cursorPositionsPublisher.sink { received.append($0) }

        // Drive a new cursor position on the active tab.
        let tab = editorManager.activeEditor.selectedTab
        tab?.cursorPositions = [CursorPosition(line: 5, column: 3)]
        cancellable.cancel()

        #expect(received.last?.first?.line == 5)
        #expect(received.last?.first?.column == 3)
    }

    @MainActor
    @Test
    func mapsRangeAndForwardsLinesInRangeSafelyWithoutTextView() {
        let editorManager = EditorManager()
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/a.swift"))
        editorManager.activeEditor.openTab(file: file)

        let state = AppActiveCursorState(editorManager: editorManager)
        let tab = editorManager.activeEditor.selectedTab
        tab?.cursorPositions = [CursorPosition(range: NSRange(location: 10, length: 4))]

        #expect(state.cursorPositions.first?.range == NSRange(location: 10, length: 4))
        // No live text view is attached in a unit test, so the forwarded query returns 0.
        #expect(state.linesInRange(NSRange(location: 10, length: 4)) == 0)
    }
}
