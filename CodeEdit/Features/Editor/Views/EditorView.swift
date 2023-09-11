//
//  EditorView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct EditorView: View {
    @ObservedObject var editor: Editor

    @FocusState.Binding var focus: Editor?

    @EnvironmentObject private var editorManager: EditorManager

    var body: some View {
        VStack {
            if let selected = editor.selectedTab {
                WorkspaceCodeFileView(file: selected)
                    .focusedObject(editor)
                    .transformEnvironment(\.edgeInsets) { insets in
                        insets.top += TabBarView.height + EditorPathBarView.height + 1 + 1
                    }
            } else {
                VStack {
                    Spacer()
                    Text("No Editor")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .frame(minHeight: 0)
                        .clipped()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    editorManager.activeEditor = editor
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                TabBarView()
                    .id("TabBarView" + editor.id.uuidString)
                    .environmentObject(editor)
                Divider()
                EditorPathBarView(file: editor.selectedTab) { [weak editor] newFile in
                    if let file = editor?.selectedTab, let index = editor?.tabs.firstIndex(of: file) {
                        editor?.openTab(item: newFile, at: index)
                    }
                }
                Divider()
            }
            .environment(\.isActiveEditor, editor == editorManager.activeEditor)
            .background(EffectView(.titlebar, blendingMode: .withinWindow, emphasized: false))
        }
        .focused($focus, equals: editor)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CodeEditor.didBeginEditing"))) { _ in
            editor.temporaryTab = nil
        }
    }
}
