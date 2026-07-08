//
//  EditorCursorPosition.swift
//  CodeEditCore
//
//  Created by Matthijs Eikelenboom.
//

import Foundation

/// The subset of an editor cursor/selection that the status bar renders, mirrored
/// as a plain value type so `CodeEditCore` need not depend on `CodeEditSourceEditor`.
public struct EditorCursorPosition: Sendable, Equatable {
    /// 1-indexed line at the start of the selection (from `CursorPosition.start.line`).
    public let line: Int
    /// 1-indexed column at the start of the selection (from `CursorPosition.start.column`).
    public let column: Int
    /// The selection range in the document.
    public let range: NSRange

    public init(line: Int, column: Int, range: NSRange) {
        self.line = line
        self.column = column
        self.range = range
    }
}
