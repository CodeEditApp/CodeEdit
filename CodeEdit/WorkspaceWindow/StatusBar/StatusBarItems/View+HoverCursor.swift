//
//  View+HoverCursor.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

extension View {

    /// Pushes or pops a cursor to match a hover state. Call from `onHover`.
    ///
    /// This is not a view modifier — it returns `Void` and mutates the cursor stack
    /// as a side effect, so it must be called inside the `onHover` closure rather
    /// than chained onto a view.
    /// - Parameters:
    ///   - isHovering: The `onHover()` value.
    ///   - isDragging: Indicates that dragging is happening. If true, the cursor is left alone.
    ///   - cursor: The cursor to display while hovering.
    func setHoverCursor(_ isHovering: Bool, isDragging: Bool = false, cursor: NSCursor = .arrow) {
        if isDragging { return }
        if isHovering {
            cursor.push()
        } else {
            NSCursor.pop()
        }
    }
}
