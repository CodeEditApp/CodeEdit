//
//  EditorView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct EditorView: View {
    @AppSettings(\.general.showEditorPathBar)
    var showEditorPathBar

    @AppSettings(\.general.dimEditorsWithoutFocus)
    var dimEditorsWithoutFocus

    @ObservedObject var editor: Editor

    @FocusState.Binding var focus: Editor?

    @EnvironmentObject private var editorManager: EditorManager

    var editorInsetAmount: Double {
        let tabBarHeight = EditorTabBarView.height + 1
        let pathBarHeight = showEditorPathBar ? (EditorPathBarView.height + 1) : 0
        return tabBarHeight + pathBarHeight
    }

    var body: some View {
        VStack {
            if let selected = editor.selectedTab {
                WorkspaceCodeFileView(file: selected)
                    .focusedObject(editor)
                    .transformEnvironment(\.edgeInsets) { insets in
                        insets.top += editorInsetAmount
                    }
                    .opacity(dimEditorsWithoutFocus && editor != editorManager.activeEditor ? 0.5 : 1)
            } else {
                CEContentUnavailableView("No Editor")
                    .padding(.top, editorInsetAmount)
                    .onTapGesture {
                        editorManager.activeEditor = editor
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                EditorTabBarView()
                    .id("TabBarView" + editor.id.uuidString)
                    .environmentObject(editor)
                Divider()
                if showEditorPathBar {
                    EditorPathBarView(file: editor.selectedTab) { [weak editor] newFile in
                        if let file = editor?.selectedTab, let index = editor?.tabs.firstIndex(of: file) {
                            editor?.openTab(item: newFile, at: index)
                        }
                    }
                    Divider()
                }
            }
            .environment(\.isActiveEditor, editor == editorManager.activeEditor)
            .background(EffectView(.headerView))
        }
        .focused($focus, equals: editor)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CodeEditor.didBeginEditing"))) { _ in
            editor.temporaryTab = nil
        }
    }
}
