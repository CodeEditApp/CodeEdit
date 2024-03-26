//
//  EditorTabBarTrailingAccessories.swift
//  CodeEdit
//
//  Created by Austin Condiff on 9/7/23.
//

import SwiftUI

struct EditorTabBarTrailingAccessories: View {
    @Environment(\.splitEditor)
    var splitEditor

    @Environment(\.modifierKeys)
    var modifierKeys

    @Environment(\.controlActiveState)
    private var activeState

    @EnvironmentObject private var editorManager: EditorManager

    @EnvironmentObject private var editor: Editor

    @AppSettings(\.general.tabBarStyle)
    var tabBarStyle

    var body: some View {
        HStack(spacing: 0) {
            splitviewButton
        }
        .padding(.horizontal, 7)
        .opacity(activeState != .inactive ? 1.0 : 0.5)
        .frame(maxHeight: .infinity) // Fill out vertical spaces.
        .background {
            if tabBarStyle == .native {
                EditorTabBarAccessoryNativeBackground(dividerAt: .leading)
            }
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
        .buttonStyle(.icon)
        .disabled(editorManager.isFocusingActiveEditor)
        .opacity(editorManager.isFocusingActiveEditor ? 0.5 : 1)
    }

    func split(edge: Edge) {
        let newEditor: Editor
        if let tab = editor.selectedTab {
            newEditor = .init(files: [tab], temporaryTab: tab)
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
        EditorTabBarTrailingAccessories()
    }
}
