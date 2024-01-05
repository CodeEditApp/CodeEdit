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

    @AppSettings(\.general.tabBarStyle)
    var tabBarStyle

    var body: some View {
        HStack(spacing: 0) {
            if let otherGroup = editorManager.editorLayout.findSomeEditor(except: editor) {
                EditorTabBarAccessoryIcon(
                    icon: .init(systemName: "multiply"),
                    action: { [weak editor] in
                        editor?.close()
                        if editorManager.activeEditor == editor {
                            editorManager.activeEditorHistory.removeAll { $0() == nil || $0() == editor }
                            if editorManager.activeEditorHistory.isEmpty {
                                editorManager.activeEditor = otherGroup
                            } else {
                                editorManager.activeEditor = editorManager.activeEditorHistory.removeFirst()()!
                            }
                        }
                        editorManager.flatten()
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
                        if !editorManager.isFocusingActiveEditor {
                            editorManager.activeEditor = editor
                        }
                        editorManager.isFocusingActiveEditor.toggle()
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
                                Text(tab.name)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .controlSize(.regular)
                        .opacity(
                            editor.historyOffset == editor.history.count-1 || editor.history.isEmpty
                            ? 0.5 : 1.0
                        )
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
                                tab.icon
                                Text(tab.name)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .controlSize(.regular)
                        .opacity(editor.historyOffset == 0 ? 0.5 : 1.0)
                } primaryAction: {
                    editorManager.activeEditor = editor
                    editor.goForwardInHistory()
                }
                .disabled(editor.historyOffset == 0)
                .help("Navigate forward")
            }
            .controlSize(.small)
            .font(EditorTabBarAccessoryIcon.iconFont)
            .frame(height: EditorTabBarView.height - 2)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
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
    }
}

struct TabBarLeadingAccessories_Previews: PreviewProvider {
    static var previews: some View {
        EditorTabBarLeadingAccessories()
    }
}
