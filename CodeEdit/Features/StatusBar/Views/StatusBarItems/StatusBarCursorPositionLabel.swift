//
//  StatusBarCursorPositionLabel.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import CodeEditCore
import CodeEditUI

struct StatusBarCursorPositionLabel: View {
    @Environment(\.activeCursorState)
    private var activeCursorState

    @Environment(\.modifierKeys)
    private var modifierKeys
    @Environment(\.controlActiveState)
    private var controlActive

    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel

    @State private var cursorPositions: [EditorCursorPosition] = []

    var body: some View {
        Group {
            if cursorPositions.isEmpty {
                Text("").accessibilityLabel("No Selection")
            } else {
                Text(getLabel())
                    .font(statusBarViewModel.statusBarFont)
                    .foregroundColor(foregroundColor)
                    .lineLimit(1)
            }
        }
        .fixedSize()
        .accessibilityIdentifier("CursorPositionLabel")
        .accessibilityAddTraits(.updatesFrequently)
        .onHover { isHovering($0) }
        .onReceive(activeCursorState.cursorPositionsPublisher) { newValue in
            self.cursorPositions = newValue
        }
    }

    private var foregroundColor: Color {
        if controlActive == .inactive {
            Color(nsColor: .disabledControlTextColor)
        } else {
            Color(nsColor: .secondaryLabelColor)
        }
    }

    /// Finds the number of lines contained by a range in the currently active document.
    /// - Parameter range: The range to query.
    /// - Returns: The number of lines in the range.
    private func getLines(_ range: NSRange) -> Int {
        activeCursorState.linesInRange(range)
    }

    /// Create a label string for cursor positions.
    /// - Returns: A string describing the user's location in a document.
    private func getLabel() -> String {
        if cursorPositions.isEmpty {
            return ""
        }

        // More than one selection, display the number of selections.
        if cursorPositions.count > 1 {
            return "\(cursorPositions.count) selected ranges"
        }

        // If the selection is more than just a cursor, return the length.
        if cursorPositions[0].range.length > 0 {
            // When the option key is pressed display the character range.
            if modifierKeys.contains(.option) {
                return "Char: \(cursorPositions[0].range.location) Len: \(cursorPositions[0].range.length)"
            }

            let lineCount = getLines(cursorPositions[0].range)

            if lineCount > 1 {
                return "\(lineCount) lines"
            }

            return "\(cursorPositions[0].range.length) characters"
        }

        // When the option key is pressed display the character offset.
        if modifierKeys.contains(.option) {
            return "Char: \(cursorPositions[0].range.location) Len: 0"
        }

        // When there's a single cursor, display the line and column.
        return "Line: \(cursorPositions[0].line)  Col: \(cursorPositions[0].column)"
    }
}
