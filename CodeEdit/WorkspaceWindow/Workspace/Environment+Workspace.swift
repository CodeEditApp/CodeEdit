//
//  Environment+Workspace.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 03/07/2026.
//

import SwiftUI
import CEWorkspaceFileManager
import CodeEditCore

private struct ActiveEditorStateKey: EnvironmentKey {
    static let defaultValue: ActiveEditorState = NoOpActiveEditorState()
}

private struct ActiveCursorStateKey: EnvironmentKey {
    static let defaultValue: ActiveCursorState = NoOpActiveCursorState()
}

private struct FileEditorOverridesKey: EnvironmentKey {
    static let defaultValue: FileEditorOverrides = NoOpFileEditorOverrides()
}

private struct WorkspaceFileManagerKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: CEWorkspaceFileManager? = nil
}

private struct WorkspaceFileURLKey: EnvironmentKey {
    static let defaultValue: URL? = nil
}

private struct WorkspaceStatePersistenceKey: EnvironmentKey {
    static let defaultValue: (any WorkspaceStatePersisting)? = nil
}

private struct WorkspaceKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: Workspace? = nil
}

private struct FilePreviewFactoryKey: EnvironmentKey {
    static let defaultValue: (CEWorkspaceFile) -> AnyView = { _ in AnyView(EmptyView()) }
}

extension EnvironmentValues {
    /// The workspace owning this view tree. `nil` only in previews or a mis-wired tree —
    /// `CodeEditSplitViewController` populates it for every real workspace window.
    var workspace: Workspace? {
        get { self[WorkspaceKey.self] }
        set { self[WorkspaceKey.self] = newValue }
    }

    /// The concrete workspace file manager, for app-shell views that need the mutating
    /// API (create/rename). Feature packages use `\.workspaceFileProvider` (CEEditor) instead.
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
