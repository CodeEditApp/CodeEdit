//
//  EditorHistoryMenus.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/8/24.
//

import SwiftUI

struct EditorHistoryMenus: View {
    @EnvironmentObject private var editorManager: EditorManager
    @EnvironmentObject private var editor: Editor

    var body: some View {
        Group {
            Menu {
                ForEach(
                    Array(editor.history.dropFirst(editor.historyOffset+1).enumerated()),
                    id: \.offset
                ) { index, file in
                    Button {
                        editorManager.activeEditor = editor
                        editor.historyOffset += index + 1
                    } label: {
                        HStack {
                            file.icon
                            Text(file.name)
                        }
                    }
                }
            } label: {
                Image(systemName: "chevron.left")
                    .opacity(editor.historyOffset == editor.history.count - 1 || editor.history.isEmpty ? 0.5 : 1)
                    .frame(height: EditorTabBarView.height - 2)
                    .padding(.horizontal, 4)
            } primaryAction: {
                editorManager.activeEditor = editor
                editor.goBackInHistory()
            }
            .disabled(editor.historyOffset == editor.history.count - 1 || editor.history.isEmpty)
            .help("Navigate back")

            Menu {
                ForEach(
                    Array(editor.history.prefix(editor.historyOffset).reversed().enumerated()),
                    id: \.offset
                ) { index, file in
                    Button {
                        editorManager.activeEditor = editor
                        editor.historyOffset -= index + 1
                    } label: {
                        HStack {
                            file.icon
                            Text(file.name)
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
}

#Preview {
    EditorHistoryMenus()
}
