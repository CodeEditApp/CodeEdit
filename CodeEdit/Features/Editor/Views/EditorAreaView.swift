//
//  EditorAreaView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI
import CodeEditTextView
import UniformTypeIdentifiers

struct EditorAreaView: View {
    @AppSettings(\.general.showEditorJumpBar)
    var showEditorJumpBar

    @AppSettings(\.navigation.navigationStyle)
    var navigationStyle

    @AppSettings(\.general.dimEditorsWithoutFocus)
    var dimEditorsWithoutFocus

    @ObservedObject var editor: Editor

    @FocusState.Binding var focus: Editor?

    @EnvironmentObject private var editorManager: EditorManager

    @State var codeFile: CodeFileDocument?

    @Environment(\.window.value)
    private var window: NSWindow?

    init(editor: Editor, focus: FocusState<Editor?>.Binding) {
        self.editor = editor
        self._focus = focus
        self.codeFile = editor.selectedTab?.file.fileDocument
    }

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
            let jumpBarHeight = showEditorJumpBar ? (EditorJumpBarView.height + 1) : 0
            return tabBarHeight + jumpBarHeight
        }

        VStack {
            if let selected = editor.selectedTab {
                if let codeFile = codeFile {
                    EditorAreaFileView(
                        codeFile: codeFile,
                        textViewCoordinators: [selected.rangeTranslator].compactMap({ $0 })
                    )
                    .focusedObject(editor)
                    .transformEnvironment(\.edgeInsets) { insets in
                        insets.top += editorInsetAmount
                    }
                    .opacity(dimEditorsWithoutFocus && editor != editorManager.activeEditor ? 0.5 : 1)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        _ = handleDrop(providers: providers)
                        return true
                    }
                } else {
                    LoadingFileView(selected.file.name)
                        .onAppear {
                            if let file = selected.file.fileDocument {
                                self.codeFile = file
                            }
                        }
                        .onReceive(selected.file.fileDocumentPublisher) { latestValue in
                            self.codeFile = latestValue
                        }
                }

            } else {
                CEContentUnavailableView("No Editor")
                    .padding(.top, editorInsetAmount)
                    .onTapGesture {
                        editorManager.activeEditor = editor
                    }
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        _ = handleDrop(providers: providers)
                        return true
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .safeAreaInset(edge: .top, spacing: 0) {
            GeometryReader { geometry in
                let topSafeArea = geometry.safeAreaInsets.top
                VStack(spacing: 0) {
                    if topSafeArea > 0 {
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 1)
                            .background(.clear)
                    }
                    if shouldShowTabBar {
                        EditorTabBarView(hasTopInsets: topSafeArea > 0)
                            .id("TabBarView" + editor.id.uuidString)
                            .environmentObject(editor)
                        Divider()
                    }
                    if showEditorJumpBar {
                        EditorJumpBarView(
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
        }
        .focused($focus, equals: editor)
        // Fixing this is causing a malloc exception when a file is edited & closed. See #1886
//        .onReceive(NotificationCenter.default.publisher(for: TextView.textDidChangeNotification)) { _ in
//            if navigationStyle == .openInTabs {
//                editor.temporaryTab = nil
//            }
//        }
        .onChange(of: navigationStyle) { newValue in
            if newValue == .openInPlace && editor.tabs.count == 1 {
                editor.temporaryTab = editor.tabs[0]
            }
        }
        .onChange(of: editor.selectedTab) { newValue in
            codeFile = newValue?.file.fileDocument
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }

                DispatchQueue.main.async {
                    let file = CEWorkspaceFile(url: url)
                    editor.openTab(file: file)
                    editorManager.activeEditor = editor
                    focus = editor
                }
            }
        }
        return true
    }
}
