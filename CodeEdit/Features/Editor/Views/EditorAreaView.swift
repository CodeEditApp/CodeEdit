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

    @State var codeFile: (() -> CodeFileDocument?)?

    @Environment(\.window.value)
    private var window: NSWindow?

    @Environment(\.isEditorLayoutAtEdge)
    private var isAtEdge

    init(editor: Editor, focus: FocusState<Editor?>.Binding) {
        self.editor = editor
        self._focus = focus
        if let file = editor.selectedTab?.file.fileDocument {
            self.codeFile = { [weak file] in file }
        }
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
            let tabBarHeight = shouldShowTabBar ? (EditorTabBarView.height) : 0
            let jumpBarHeight = showEditorJumpBar ? (EditorJumpBarView.height) : 0
            return tabBarHeight + jumpBarHeight
        }

        VStack {
            if let selected = editor.selectedTab {
                if let codeFile = codeFile?() {
                    EditorAreaFileView(editorInstance: selected, codeFile: codeFile)
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
                                self.codeFile = { [weak file] in file }
                            }
                        }
                        .onReceive(selected.file.fileDocumentPublisher) { latestValue in
                            self.codeFile = { [weak latestValue] in latestValue }
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
                let fileBinding = Binding {
                    codeFile?()
                } set: { newFile in
                    codeFile = { [weak newFile] in newFile }
                }

                VStack(spacing: 0) {
                    if isAtEdge != .top, #available(macOS 26, *) {
                        Spacer().frame(height: 4)
                    }

                    if topSafeArea > 0 {
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 1)
                            .background(.clear)
                    }
                    if shouldShowTabBar {
                        EditorTabBarView(hasTopInsets: topSafeArea > 0, codeFile: fileBinding)
                            .id("TabBarView" + editor.id.uuidString)
                            .environmentObject(editor)
                        if #unavailable(macOS 26) {
                            Divider()
                        }
                    }
                    if showEditorJumpBar {
                        EditorJumpBarView(
                            file: editor.selectedTab?.file,
                            shouldShowTabBar: shouldShowTabBar,
                            codeFile: fileBinding
                        ) { [weak editor] newFile in
                            if let file = editor?.selectedTab, let index = editor?.tabs.firstIndex(of: file) {
                                editor?.openTab(file: newFile, at: index)
                            }
                        }
                        .environmentObject(editor)
                        .padding(.top, shouldShowTabBar ? -1 : 0)
                        if #unavailable(macOS 26) {
                            Divider()
                        }
                    }
                    // On Tahoe we only show one divider
                    if #available(macOS 26, *), shouldShowTabBar || showEditorJumpBar {
                        Divider()
                    }
                }
                .environment(\.isActiveEditor, editor == editorManager.activeEditor)
                .if(.tahoe) {
                    // FB20047271: Glass toolbar effect ignores floating scroll view views.
                    // https://openradar.appspot.com/radar?id=EhAKBVJhZGFyEICAgKbGmesJ

                    // FB20191516: Can't disable backgrounded liquid glass tint
                    // https://openradar.appspot.com/radar?id=EhAKBVJhZGFyEICAgLqTk-4J
                    // Tracking Issue: #2191
                    // Add this to the top:
                    // ```
                    // @AppSettings(\.theme.useThemeBackground)
                    // var useThemeBackground
                    //
                    // private var backgroundColor: NSColor {
                    //     let fallback = NSColor.textBackgroundColor
                    //     return if useThemeBackground {
                    //         ThemeModel.shared.selectedTheme?.editor.background.nsColor ?? fallback
                    //     } else {
                    //         fallback
                    //     }
                    // }
                    // ```
                    // And use this:
                    // ```
                    // $0.background(
                    //    Rectangle().fill(.clear)
                    //        .glassEffect(.regular.tint(Color(backgroundColor))
                    //        .ignoresSafeArea(.all)
                    // )
                    // ```
                    // When we can figure out how to disable the 'not focused' glass effect.

                    $0.background(EffectView(.headerView).ignoresSafeArea(.all))
                } else: {
                    $0.background(EffectView(.headerView))
                }
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
            if let file = newValue?.file.fileDocument {
                codeFile = { [weak file] in file }
            }
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
                    editorManager.activeEditor = editor
                    editor.openTab(file: file)
                }
            }
        }
        return true
    }
}
