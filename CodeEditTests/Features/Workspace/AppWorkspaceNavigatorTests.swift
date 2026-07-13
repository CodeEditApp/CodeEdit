//
//  AppWorkspaceNavigatorTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Testing
import CodeEditCore
@testable import CodeEdit
@testable import CEEditor

@Suite
struct AppWorkspaceNavigatorTests {
    @MainActor
    final class MockWindowManager: WorkspaceWindowManaging {
        var opened: [(url: URL, asTemporary: Bool)] = []
        var openWorkspaces: [Workspace] = []
        var stubbedWorkspace: Workspace?
        func openWorkspace(at url: URL) throws {}
        func closeWorkspace(_ workspace: Workspace) {}
        func workspace(containing url: URL) -> Workspace? { stubbedWorkspace }
        func openFileInWorkspace(url: URL, asTemporary: Bool) -> Bool {
            opened.append((url, asTemporary))
            return true
        }
        func openDocumentFromPanel() {}
        func newDocumentFromPanel() {}
        func openDocument(at url: URL, onCompletion: @escaping () -> Void) {}
        func openDocumentWithDialog(
            canChooseFiles: Bool,
            canChooseDirectories: Bool,
            onDialogPresented: (() -> Void)?,
            onCancel: (() -> Void)?
        ) {}
    }

    @MainActor
    @Test
    func openDelegatesToWindowManagerWithTemporaryFlag() {
        let mock = MockWindowManager()
        let navigator = AppWorkspaceNavigator(windowManager: mock)
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/example.swift"))

        navigator.open(file: file, asTemporary: true)

        #expect(mock.opened.count == 1)
        #expect(mock.opened.first?.url == file.url)
        #expect(mock.opened.first?.asTemporary == true)
    }

    @MainActor
    @Test
    func revealSetsHighlightedFileItemOnCorrectWorkspace() throws {
        let workspace = try TestWorkspaceFactory.make()
        let mock = MockWindowManager()
        mock.stubbedWorkspace = workspace
        let navigator = AppWorkspaceNavigator(windowManager: mock)
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/example.swift"))

        navigator.reveal(file: file)

        #expect(workspace.listenerModel.highlightedFileItem === file)
    }

    @MainActor
    @Test
    func closeTabClosesFileInEditorLayout() throws {
        let workspace = try TestWorkspaceFactory.make()
        let editorManager = workspace.editorManager
        let mock = MockWindowManager()
        mock.stubbedWorkspace = workspace
        let navigator = AppWorkspaceNavigator(windowManager: mock)
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/example.swift"))

        editorManager.activeEditor.openTab(file: file, asTemporary: false)
        #expect(editorManager.activeEditor.tabs.contains(where: { $0.file == file }))

        navigator.closeTab(file: file)
        #expect(!editorManager.activeEditor.tabs.contains(where: { $0.file == file }))
    }
}
