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

@Suite
struct AppWorkspaceNavigatorTests {
    @MainActor
    final class MockWindowManager: WorkspaceWindowManaging {
        var opened: [(url: URL, asTemporary: Bool)] = []
        var openWorkspaces: [Workspace] = []
        func openWorkspace(at url: URL) throws {}
        func closeWorkspace(_ workspace: Workspace) {}
        func workspace(containing url: URL) -> Workspace? { nil }
        func openFileInWorkspace(url: URL, asTemporary: Bool) -> Bool {
            opened.append((url, asTemporary))
            return true
        }
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
}
