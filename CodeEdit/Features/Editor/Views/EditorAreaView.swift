//
//  EditorAreaView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct EditorAreaView: View {
    @AppSettings(\.general.showEditorPathBar)
    var showEditorPathBar

    @AppSettings(\.navigation.navigationStyle)
    var navigationStyle

    @AppSettings(\.general.dimEditorsWithoutFocus)
    var dimEditorsWithoutFocus

    @ObservedObject var editor: Editor

    @FocusState.Binding var focus: Editor?

    @EnvironmentObject private var editorManager: EditorManager

    var body: some View {
        var shouldShowTabBar: Bool {
            return navigationStyle == .openInTabs
            || editorManager.flattenedEditors.contains { editor in
                (editor.temporaryTab == nil && !editor.tabs.isEmpty)
                || (editor.temporaryTab != nil && editor.tabs.count > 1)
            }
        }

        var editorInsetAmount: Double {
            let tabBarHeight = shouldShowTabBar ? (EditorTabBarView.height + 1) : 0
            let pathBarHeight = showEditorPathBar ? (EditorPathBarView.height + 1) : 0
            return tabBarHeight + pathBarHeight
        }

        VStack {
            if let selected = editor.selectedTab {
                EditorAreaFileView(
                    file: selected.file,
                    textViewCoordinators: [selected.rangeTranslator].compactMap({ $0 })
                )
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
                if shouldShowTabBar {
                    EditorTabBarView()
                        .id("TabBarView" + editor.id.uuidString)
                        .environmentObject(editor)
                    Divider()
                }
                if showEditorPathBar {
                    EditorPathBarView(
                        file: editor.selectedTab?.file,
                        shouldShowTabBar: shouldShowTabBar
                    ) { [weak editor] newFile in
                        if let file = editor?.selectedTab, let index = editor?.tabs.firstIndex(of: file) {
                            editor?.openTab(file: newFile, at: index)
                        }
                    }
                    .environmentObject(editor)
                    .padding(.top, shouldShowTabBar ? -1 : 0)
                    Divider()
                }
            }
            .environment(\.isActiveEditor, editor == editorManager.activeEditor)
            .background(EffectView(.headerView))
        }
        .focused($focus, equals: editor)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CodeEditor.didBeginEditing"))) { _ in
            if navigationStyle == .openInTabs {
                editor.temporaryTab = nil
            }
        }
        .onChange(of: navigationStyle) { newValue in
            if newValue == .openInPlace && editor.tabs.count == 1 {
                editor.temporaryTab = editor.tabs[0]
            }
        }
    }
}
