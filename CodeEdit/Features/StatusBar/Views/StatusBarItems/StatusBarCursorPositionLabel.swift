//
//  StatusBarCursorPositionLabel.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import Combine
import CodeEditSourceEditor

struct StatusBarCursorPositionLabel: View {
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel
    @EnvironmentObject private var editorManager: EditorManager

    @State private var tab: EditorInstance?

    /// Updates the source of cursor position notifications.
    func updateSource() {
        tab = editorManager.activeEditor.selectedTab
    }

    var body: some View {
        Group {
            if let currentTab = tab {
                // Identity by object, not file equality — ``EditorInstance`` compares equal by file.
                LineLabel(editorInstance: currentTab)
                    .id(ObjectIdentifier(currentTab))
            } else {
                Text("").accessibilityLabel("No Selection")
            }
        }
        .fixedSize()
        .accessibilityIdentifier("CursorPositionLabel")
        .accessibilityAddTraits(.updatesFrequently)
        .onHover { isHovering($0) }
        .onAppear {
            updateSource()
        }
        .onReceive(editorManager.tabBarTabIdSubject) { _ in
            updateSource()
        }
        .onReceive(editorManager.$activeEditor) { _ in
            updateSource()
        }
        .onChange(of: editorManager.activeEditor.selectedTab) { _, newTab in
            tab = newTab
        }
    }

    /// Formats the status-bar cursor label from cursor positions.
    ///
    /// Extracted for unit testing. When line/column are unresolved (`<= 0`), falls back to a safe
    /// `Line: 1  Col: 1` caret label (or character offset when Option is held).
    static func formatLabel(
        cursorPositions: [CursorPosition],
        optionKeyPressed: Bool,
        linesInRange: (NSRange) -> Int
    ) -> String {
        if cursorPositions.isEmpty {
            return ""
        }

        // More than one selection, display the number of selections.
        if cursorPositions.count > 1 {
            return "\(cursorPositions.count) selected ranges"
        }

        let position = cursorPositions[0]

        // If the selection is more than just a cursor, return the length.
        if position.range.length > 0 {
            // When the option key is pressed display the character range.
            if optionKeyPressed {
                return "Char: \(position.range.location) Len: \(position.range.length)"
            }

            let lineCount = linesInRange(position.range)

            if lineCount > 1 {
                return "\(lineCount) lines"
            }

            return "\(position.range.length) characters"
        }

        // When the option key is pressed display the character offset.
        if optionKeyPressed {
            if position.range != .notFound {
                return "Char: \(position.range.location) Len: 0"
            }
            return "Char: 0 Len: 0"
        }

        // Unresolved line/column (range-only positions from SourceEditor) until the controller fills them in.
        if position.start.line <= 0 || position.start.column <= 0 {
            return "Line: 1  Col: 1"
        }

        // When there's a single cursor, display the line and column.
        return "Line: \(position.start.line)  Col: \(position.start.column)"
    }

    struct LineLabel: View {
        @Environment(\.modifierKeys)
        private var modifierKeys
        @Environment(\.controlActiveState)
        private var controlActive

        @EnvironmentObject private var statusBarViewModel: StatusBarViewModel

        let editorInstance: EditorInstance

        @State private var cursorPositions: [CursorPosition]

        init(editorInstance: EditorInstance) {
            self.editorInstance = editorInstance
            self._cursorPositions = State(initialValue: editorInstance.cursorPositions)
        }

        var body: some View {
            Text(getLabel())
                .font(statusBarViewModel.statusBarFont)
                .foregroundColor(foregroundColor)
                .lineLimit(1)
                .onAppear {
                    cursorPositions = editorInstance.cursorPositions
                }
                .onReceive(editorInstance.$cursorPositions) { newValue in
                    self.cursorPositions = newValue
                }
                .onReceive(editorInstance.rangeTranslator.controllerDidAppearSubject) { _ in
                    self.cursorPositions = editorInstance.cursorPositions.map {
                        editorInstance.rangeTranslator.resolveCursorPosition($0)
                    }
                }
        }

        private var foregroundColor: Color {
            if controlActive == .inactive {
                Color(nsColor: .disabledControlTextColor)
            } else {
                Color(nsColor: .secondaryLabelColor)
            }
        }

        /// Finds the lines contained by a range in the currently selected document.
        /// - Parameter range: The range to query.
        /// - Returns: The number of lines in the range.
        func getLines(_ range: NSRange) -> Int {
            return editorInstance.rangeTranslator.linesInRange(range)
        }

        /// Create a label string for cursor positions.
        /// - Returns: A string describing the user's location in a document.
        func getLabel() -> String {
            let resolved = cursorPositions.map { editorInstance.rangeTranslator.resolveCursorPosition($0) }
            return StatusBarCursorPositionLabel.formatLabel(
                cursorPositions: resolved,
                optionKeyPressed: modifierKeys.contains(.option),
                linesInRange: getLines
            )
        }
    }
}
