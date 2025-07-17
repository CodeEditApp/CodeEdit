//
//  EditorTabBarTrailingAccessories.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/7/23.
//

import SwiftUI

struct EditorTabBarTrailingAccessories: View {
    @AppSettings(\.textEditing.wrapLinesToEditorWidth)
    var wrapLinesToEditorWidth
    @AppSettings(\.textEditing.showMinimap)
    var showMinimap

    @Environment(\.splitEditor)
    var splitEditor

    @Environment(\.modifierKeys)
    var modifierKeys

    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject var workspace: WorkspaceDocument

    @EnvironmentObject private var editorManager: EditorManager

    @EnvironmentObject private var editor: Editor

    @Binding var codeFile: CodeFileDocument?

    var body: some View {
        HStack(spacing: 6) {
            // Once more options are implemented that are available for non-code documents, remove this if statement
            if let codeFile {
                editorOptionsMenu(codeFile: codeFile)
                Divider()
                    .padding(.vertical, 10)
            }
            splitviewButton
        }
        .buttonStyle(.icon)
        .disabled(editorManager.isFocusingActiveEditor)
        .opacity(editorManager.isFocusingActiveEditor ? 0.5 : 1)
        .padding(.horizontal, 7)
        .opacity(activeState != .inactive ? 1.0 : 0.5)
        .frame(maxHeight: .infinity) // Fill out vertical spaces.
    }

    func editorOptionsMenu(codeFile: CodeFileDocument) -> some View {
        // This is a button so it gets the same styling from the Group in `body`.
        Button(action: {}, label: { Image(systemName: "slider.horizontal.3") })
            .overlay {
                Menu {
                    Toggle("Show Minimap", isOn: $showMinimap)
                        .keyboardShortcut("M", modifiers: [.command, .shift, .control])
                    Divider()
                    Toggle(
                        "Wrap Lines",
                        isOn: Binding(
                            get: { [weak codeFile] in codeFile?.wrapLines ?? wrapLinesToEditorWidth },
                            set: { [weak codeFile] in
                                codeFile?.wrapLines = $0
                            }
                        )
                    )
                } label: {}
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
            }
    }

    var splitviewButton: some View {
        Group {
            switch (editor.parent?.axis, modifierKeys.contains(.option)) {
            case (.horizontal, true), (.vertical, false):
                Button {
                    split(edge: .bottom)
                } label: {
                    Image(symbol: "square.split.horizontal.plus")
                }
                .help("Split Vertically")

            case (.vertical, true), (.horizontal, false):
                Button {
                    split(edge: .trailing)
                } label: {
                    Image(symbol: "square.split.vertical.plus")
                }
                .help("Split Horizontally")

            default:
                EmptyView()
            }
        }
    }

    func split(edge: Edge) {
        let newEditor: Editor
        if let tab = editor.selectedTab {
            newEditor = .init(files: [tab], temporaryTab: tab, workspace: workspace)
        } else {
            newEditor = .init()
        }
        splitEditor(edge, newEditor)
        editorManager.updateCachedFlattenedEditors = true
        editorManager.activeEditor = newEditor
    }
}

struct TabBarTrailingAccessories_Previews: PreviewProvider {
    static var previews: some View {
        EditorTabBarTrailingAccessories(codeFile: .constant(nil))
    }
}
