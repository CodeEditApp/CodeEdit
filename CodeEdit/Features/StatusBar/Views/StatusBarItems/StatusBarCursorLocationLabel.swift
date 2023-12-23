//
//  StatusBarCursorLocationLabel.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import CodeEditSourceEditor

struct StatusBarCursorLocationLabel: View {
    @Environment(\.controlActiveState)
    private var controlActive

    @EnvironmentObject private var model: UtilityAreaViewModel
    @EnvironmentObject private var editorManager: EditorManager

    @State private var file: CEWorkspaceFile?
    @State private var cursorPositions: [CursorPosition]?

    func updateSource() {
        file = editorManager.activeEditor.selectedTab
    }

    func getLines(_ range: NSRange) -> Int {
        if let fileDocument = file?.fileDocument {
            return fileDocument.rangeTranslator.linesInRange(range)
        }

        return 0
    }

    func getLabel(_ cursorPositions: [CursorPosition]) -> String {
        if cursorPositions.isEmpty {
            return ""
        }

        if cursorPositions.count > 1 {
            return "\(cursorPositions.count) selected ranges"
        }

        if cursorPositions[0].range.length > 0 {
            let lineCount = getLines(cursorPositions[0].range)

            if lineCount > 1 {
                return "\(lineCount) lines"
            }

            return "\(cursorPositions[0].range.length) characters"
        }

        return "Line: \(cursorPositions[0].line)  Col: \(cursorPositions[0].column)"
    }

    var body: some View {
        Group {
            if let currentFile = file, let fileDocument = currentFile.fileDocument {
                Group {
                    if let cursorPositions = cursorPositions {
                        Text(getLabel(cursorPositions))
                    } else {
                        EmptyView()
                    }
                }
                .onReceive(fileDocument.$cursorPositions) { val in
                    cursorPositions = val
                }
            } else {
                EmptyView()
            }
        }
        .font(model.toolbarFont)
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
