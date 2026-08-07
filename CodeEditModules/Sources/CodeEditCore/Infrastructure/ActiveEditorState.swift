//
//  ActiveEditorState.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Combine

/// Read-model for the workspace's currently active file. Lets StatusBar / Inspector /
/// Navigator observe "which file is active" without depending on the Editor feature's
/// `EditorManager`/`Editor`/`EditorInstance`. Workspace-scoped: one per window.
public protocol ActiveEditorState: AnyObject {
    @MainActor var selectedFile: CEWorkspaceFile? { get }
    @MainActor var selectedFilePublisher: AnyPublisher<CEWorkspaceFile?, Never> { get }
}

/// Default used when no editor state is injected (tests, previews); reports no active file.
public final class NoOpActiveEditorState: ActiveEditorState {
    public init() {}
    public var selectedFile: CEWorkspaceFile? { nil }
    public var selectedFilePublisher: AnyPublisher<CEWorkspaceFile?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
}
