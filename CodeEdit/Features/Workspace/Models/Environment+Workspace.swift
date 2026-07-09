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

private struct ActiveCursorStateKey: EnvironmentKey {
    static let defaultValue: ActiveCursorState = NoOpActiveCursorState()
}

private struct FileEditorOverridesKey: EnvironmentKey {
    static let defaultValue: FileEditorOverrides = NoOpFileEditorOverrides()
}

private struct WorkspaceFileURLKey: EnvironmentKey {
    static let defaultValue: URL? = nil
}

private struct WorkspaceStatePersistenceKey: EnvironmentKey {
    static let defaultValue: (any WorkspaceStatePersisting)? = nil
}

private struct FilePreviewFactoryKey: EnvironmentKey {
    static let defaultValue: (CEWorkspaceFile) -> AnyView = { _ in AnyView(EmptyView()) }
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

    var activeCursorState: ActiveCursorState {
        get { self[ActiveCursorStateKey.self] }
        set { self[ActiveCursorStateKey.self] = newValue }
    }

    var fileEditorOverrides: FileEditorOverrides {
        get { self[FileEditorOverridesKey.self] }
        set { self[FileEditorOverridesKey.self] = newValue }
    }

    var filePreview: (CEWorkspaceFile) -> AnyView {
        get { self[FilePreviewFactoryKey.self] }
        set { self[FilePreviewFactoryKey.self] = newValue }
    }
}
