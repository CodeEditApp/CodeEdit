//
//  Environment+Workspace.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 03/07/2026.
//

import SwiftUI
import CEWorkspaceFileManager
import CodeEditCore

private struct WorkspaceFileManagerKey: EnvironmentKey {
    static let defaultValue: CEWorkspaceFileManager? = nil
}

private struct ActiveEditorStateKey: EnvironmentKey {
    static let defaultValue: ActiveEditorState = NoOpActiveEditorState()
}

private struct WorkspaceFileURLKey: EnvironmentKey {
    static let defaultValue: URL? = nil
}

private struct WorkspaceStatePersistenceKey: EnvironmentKey {
    static let defaultValue: (any WorkspaceStatePersisting)? = nil
}

extension EnvironmentValues {
    var workspaceFileManager: CEWorkspaceFileManager? {
        get { self[WorkspaceFileManagerKey.self] }
        set { self[WorkspaceFileManagerKey.self] = newValue }
    }

    var workspaceFileURL: URL? {
        get { self[WorkspaceFileURLKey.self] }
        set { self[WorkspaceFileURLKey.self] = newValue }
    }

    var workspaceStatePersistence: (any WorkspaceStatePersisting)? {
        get { self[WorkspaceStatePersistenceKey.self] }
        set { self[WorkspaceStatePersistenceKey.self] = newValue }
    }

    var activeEditorState: ActiveEditorState {
        get { self[ActiveEditorStateKey.self] }
        set { self[ActiveEditorStateKey.self] = newValue }
    }
}
