//
//  AppWorkspaceNavigatorTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Testing
import Combine
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
    func openFileAtURLResolvesThroughWorkspaceFileManagerAndPreservesTemporaryFlag() throws {
        let workspace = try TestWorkspaceFactory.make()
        let fileURL = workspace.fileURL.appending(path: "example.swift")
        try "// example".write(to: fileURL, atomically: true, encoding: .utf8)

        let mock = MockWindowManager()
        mock.stubbedWorkspace = workspace
        let navigator = AppWorkspaceNavigator(windowManager: mock)

        navigator.open(fileAt: fileURL, asTemporary: true)

        #expect(mock.opened.count == 1)
        #expect(mock.opened.first?.url == fileURL)
        #expect(mock.opened.first?.asTemporary == true)
    }

    /// Regression test for the case the old unsorted `workspace(containing:)` probe could miss:
    /// `open(fileAt:)` must still open the file via `openFileInWorkspace` (the sorted,
    /// nearest-workspace path) even when the unsorted probe would have returned nil.
    @MainActor
    @Test
    func openFileAtURLOpensEvenWhenWorkspaceContainingProbeMisses() throws {
        let mock = MockWindowManager()
        // Deliberately leave `stubbedWorkspace` nil so `workspace(containing:)` returns nil,
        // simulating the unsorted probe missing a URL that the sorted path would still resolve.
        let navigator = AppWorkspaceNavigator(windowManager: mock)
        let fileURL = URL(fileURLWithPath: "/tmp/unmatched-by-probe.swift")

        navigator.open(fileAt: fileURL, asTemporary: false)

        #expect(mock.opened.count == 1)
        #expect(mock.opened.first?.url == fileURL)
        #expect(mock.opened.first?.asTemporary == false)
    }

    @MainActor
    @Test
    func revealSendsRevealRequestOnCorrectWorkspace() throws {
        let workspace = try TestWorkspaceFactory.make()
        let mock = MockWindowManager()
        mock.stubbedWorkspace = workspace
        let navigator = AppWorkspaceNavigator(windowManager: mock)
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/example.swift"))

        var revealed: [CEWorkspaceFile] = []
        let cancellable = workspace.revealRequests.sink { revealed.append($0) }
        defer { cancellable.cancel() }

        navigator.reveal(file: file)

        #expect(revealed.count == 1)
        #expect(revealed.first === file)
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
