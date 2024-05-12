//
//  StatusBarCursorPositionLabel.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import CodeEditSourceEditor

struct StatusBarCursorPositionLabel: View {
    @Environment(\.controlActiveState)
    private var controlActive
    @Environment(\.modifierKeys)
    private var modifierKeys

    @EnvironmentObject private var statusBarViewModel: StatusBarViewModel
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @EnvironmentObject private var editorManager: EditorManager

    @State private var tab: EditorInstance?
    @State private var cursorPositions: [CursorPosition]?

    /// Updates the source of cursor position notifications.
    func updateSource() {
        tab = editorManager.activeEditor.selectedTab
    }

    /// Finds the lines contained by a range in the currently selected document.
    /// - Parameter range: The range to query.
    /// - Returns: The number of lines in the range.
    func getLines(_ range: NSRange) -> Int {
        return tab?.rangeTranslator?.linesInRange(range) ?? 0
    }

    /// Create a label string for cursor positions.
    /// - Parameter cursorPositions: The cursor positions to create the label for.
    /// - Returns: A string describing the user's location in a document.
    func getLabel(_ cursorPositions: [CursorPosition]) -> String {
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

    var body: some View {
        Group {
            if let currentTab = tab {
                Group {
                    if let cursorPositions = cursorPositions {
                        Text(getLabel(cursorPositions))
                    } else {
                        EmptyView()
                    }
                }
                .onReceive(currentTab.cursorPositions) { val in
                    cursorPositions = val
                }
            } else {
                EmptyView()
            }
        }
        .font(statusBarViewModel.statusBarFont)
        .foregroundColor(foregroundColor)
        .fixedSize()
        .lineLimit(1)
        .onHover { isHovering($0) }
        .onAppear {
            updateSource()
        }
        .onReceive(editorManager.activeEditor.objectWillChange) { _ in
            updateSource()
        }
        .onChange(of: editorManager.activeEditor) { _ in
            updateSource()
        }
        .onChange(of: editorManager.activeEditor.selectedTab) { _ in
            updateSource()
        }
    }

    private var foregroundColor: Color {
        controlActive == .inactive ? Color(nsColor: .disabledControlTextColor) : Color(nsColor: .secondaryLabelColor)
    }
}
