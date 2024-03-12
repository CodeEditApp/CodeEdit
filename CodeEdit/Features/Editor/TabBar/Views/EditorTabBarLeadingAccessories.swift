//
//  EditorTabBarLeadingAccessories.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/7/23.
//

import SwiftUI

struct EditorTabBarLeadingAccessories: View {
    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject private var editorManager: EditorManager

    @EnvironmentObject private var editor: Editor

    @State private var otherEditor: Editor?

    @AppSettings(\.general.tabBarStyle)
    var tabBarStyle

    var body: some View {
        HStack(spacing: 0) {
            if let otherEditor {
                EditorTabBarAccessoryIcon(
                    icon: .init(systemName: "multiply"),
                    action: { [weak editor] in
                        guard let editor else { return }
                        editorManager.closeEditor(editor)
                    }
                )
                .help("Close this Editor")
                .disabled(editorManager.isFocusingActiveEditor)
                .opacity(editorManager.isFocusingActiveEditor ? 0.5 : 1)

                EditorTabBarAccessoryIcon(
                    icon: .init(
                        systemName: editorManager.isFocusingActiveEditor
                        ? "arrow.down.forward.and.arrow.up.backward"
                        : "arrow.up.left.and.arrow.down.right"
                    ),
                    isActive: editorManager.isFocusingActiveEditor,
                    action: {
                        editorManager.toggleFocusingEditor(from: editor)
                    }
                )
                .help(
                    editorManager.isFocusingActiveEditor
                    ? "Unfocus this Editor"
                    : "Focus this Editor"
                )

                Divider()
                    .frame(height: 10)
                    .padding(.horizontal, 4)
            }

            Group {
                Menu {
                    ForEach(
                        Array(editor.history.dropFirst(editor.historyOffset+1).enumerated()),
                        id: \.offset
                    ) { index, tab in
                        Button {
                            editorManager.activeEditor = editor
                            editor.historyOffset += index + 1
                        } label: {
                            HStack {
                                tab.file.icon
                                Text(tab.file.name)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .opacity(editor.historyOffset == editor.history.count-1 || editor.history.isEmpty ? 0.5 : 1)
                        .frame(height: EditorTabBarView.height - 2)
                        .padding(.horizontal, 4)
                } primaryAction: {
                    editorManager.activeEditor = editor
                    editor.goBackInHistory()
                }
                .disabled(editor.historyOffset == editor.history.count-1 || editor.history.isEmpty)
                .help("Navigate back")

                Menu {
                    ForEach(
                        Array(editor.history.prefix(editor.historyOffset).reversed().enumerated()),
                        id: \.offset
                    ) { index, tab in
                        Button {
                            editorManager.activeEditor = editor
                            editor.historyOffset -= index + 1
                        } label: {
                            HStack {
                                tab.file.icon
                                Text(tab.file.name)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .opacity(editor.historyOffset == 0 ? 0.5 : 1)
                        .frame(height: EditorTabBarView.height - 2)
                        .padding(.horizontal, 4)
                } primaryAction: {
                    editorManager.activeEditor = editor
                    editor.goForwardInHistory()
                }
                .disabled(editor.historyOffset == 0)
                .help("Navigate forward")
            }
            .buttonStyle(.icon)
            .controlSize(.small)
            .font(EditorTabBarAccessoryIcon.iconFont)
        }
        .foregroundColor(.secondary)
        .buttonStyle(.plain)
        .padding(.horizontal, 5)
        .opacity(activeState != .inactive ? 1.0 : 0.5)
        .frame(maxHeight: .infinity) // Fill out vertical spaces.
        .background {
            if tabBarStyle == .native {
                EditorTabBarAccessoryNativeBackground(dividerAt: .trailing)
            }
        }
        .onAppear {
            otherEditor = editorManager.editorLayout.findSomeEditor(except: editor)
        }
        .onReceive(editorManager.objectWillChange) { _ in
            otherEditor = editorManager.editorLayout.findSomeEditor(except: editor)
        }
    }
}
