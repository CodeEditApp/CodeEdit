//
//  AppActiveEditorStateTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Combine
import Testing
import CodeEditCore
import CEWorkspaceFileManager
@testable import CEEditor
@testable import CodeEdit

@Suite
struct AppActiveEditorStateTests {
    @MainActor
    @Test
    func reflectsAndPublishesActiveFile() {
        let editorManager = EditorManager()
        let fileA = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/a.swift"))
        editorManager.activeEditor.openTab(file: fileA)

        let state = AppActiveEditorState(editorManager: editorManager)
        #expect(state.selectedFile?.url == fileA.url)

        var received: [URL?] = []
        let cancellable = state.selectedFilePublisher.sink { received.append($0?.url) }

        let fileB = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/b.swift"))
        editorManager.activeEditor.openTab(file: fileB)
        cancellable.cancel()

        // Current value replayed on subscribe (fileA) then fileB after the switch.
        #expect(received.first == fileA.url)
        #expect(received.last == fileB.url)
    }
}
