//
//  ActiveCursorState.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

import Foundation
import Combine

/// Read-model for the currently active editor's cursor/selection. Lets the status
/// bar render cursor position without depending on the Editor feature's
/// `EditorManager` / `EditorInstance` or the `CodeEditSourceEditor` widget.
/// Workspace-scoped: one per window.
public protocol ActiveCursorState: AnyObject {
    @MainActor var cursorPositions: [EditorCursorPosition] { get }
    @MainActor var cursorPositionsPublisher: AnyPublisher<[EditorCursorPosition], Never> { get }
    /// Number of lines contained by `range` in the active editor's live text view.
    /// Returns 0 when there is no active editor or the lines cannot be resolved.
    @MainActor func linesInRange(_ range: NSRange) -> Int
}

/// Default used when no cursor state is injected (tests, previews); reports no cursor.
public final class NoOpActiveCursorState: ActiveCursorState {
    public init() {}
    public var cursorPositions: [EditorCursorPosition] { [] }
    public var cursorPositionsPublisher: AnyPublisher<[EditorCursorPosition], Never> {
        Just([]).eraseToAnyPublisher()
    }
    public func linesInRange(_ range: NSRange) -> Int { 0 }
}
