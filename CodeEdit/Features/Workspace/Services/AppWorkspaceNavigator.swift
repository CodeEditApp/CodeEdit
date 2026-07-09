//
//  AppWorkspaceNavigator.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import CodeEditCore
import CEWorkspaceFileManager
import Factory

/// App-shell binding of the `WorkspaceNavigator` command interface.
/// Delegates to `WorkspaceWindowManager.openFileInWorkspace(url:asTemporary:)`, which maps the
/// file's URL to the workspace that owns it, opens the tab, and focuses that workspace.
final class AppWorkspaceNavigator: WorkspaceNavigator {
    private let windowManager: WorkspaceWindowManaging

    init(windowManager: WorkspaceWindowManaging = Container.shared.workspaceWindowManager()) {
        self.windowManager = windowManager
    }

    @MainActor
    func open(file: CEWorkspaceFile, asTemporary: Bool) {
        _ = windowManager.openFileInWorkspace(url: file.url, asTemporary: asTemporary)
    }

    @MainActor
    func reveal(file: CEWorkspaceFile) {
        windowManager.workspace(containing: file.url)?.listenerModel.highlightedFileItem = file
    }
}
