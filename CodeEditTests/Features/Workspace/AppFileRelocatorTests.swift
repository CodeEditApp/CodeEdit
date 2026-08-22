//
//  AppFileRelocatorTests.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Testing
import CodeEditCore
@testable import CodeEdit

@Suite
struct AppFileRelocatorTests {
    @MainActor
    final class MockWindowManager: WorkspaceWindowManaging {
        var queried: [URL] = []
        var openWorkspaces: [Workspace] = []
        func openWorkspace(at url: URL) throws {}
        func closeWorkspace(_ workspace: Workspace) {}
        func workspace(containing url: URL) -> Workspace? {
            queried.append(url)
            return nil
        }
        func openFileInWorkspace(url: URL, asTemporary: Bool) -> Bool { false }
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
    func returnsNilAndQueriesByURLWhenWorkspaceUnresolved() throws {
        let mock = MockWindowManager()
        let relocator = AppFileRelocator(windowManager: mock)
        let file = CEWorkspaceFile(url: URL(fileURLWithPath: "/tmp/a.swift"))

        let result = try relocator.relocate(file: file, to: URL(fileURLWithPath: "/tmp/b.swift"))

        #expect(result == nil)
        #expect(mock.queried == [file.url])
    }
}
