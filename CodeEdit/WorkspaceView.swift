//
//  WorkspaceView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import AppKit

struct WorkspaceView: View {

    let tabBarHeight = 28.0
    private var path: String = ""

    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var editorManager: EditorManager
    @EnvironmentObject private var utilityAreaModel: UtilityAreaViewModel
    @Environment(\.window)
    private var window: NSWindow

    private var keybindings: KeybindingManager =  .shared

    @State private var showingAlert = false

    @Environment(\.colorScheme)
    private var colorScheme

    @AppSettings(\.theme.matchAppearance)
    var matchAppearance

    @StateObject private var themeModel: ThemeModel = .shared

    @State private var terminalCollapsed = true

    @State private var editorCollapsed = false

    @FocusState var focusedEditor: Editor?

    var body: some View {
        if workspace.workspaceFileManager != nil {
            VStack {
                SplitViewReader { proxy in
                    SplitView(axis: .vertical) {
                        EditorView(
                            layout: editorManager.isFocusingActiveEditor
                            ? editorManager.activeEditor.getEditorLayout() ?? editorManager.editorLayout
                            : editorManager.editorLayout,
                            focus: $focusedEditor
                        )
                        .collapsable()
                        .collapsed($utilityAreaModel.isMaximized)
                        .frame(minHeight: 170 + 29 + 29)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .holdingPriority(.init(1))
                        .safeAreaInset(edge: .bottom, spacing: 0) {
                            StatusBarView(proxy: proxy)
                        }
                        UtilityAreaView()
                            .collapsable()
                            .collapsed($utilityAreaModel.isCollapsed)
                            .frame(idealHeight: 260)
                            .frame(minHeight: 100)
                    }
                    .edgesIgnoringSafeArea(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: focusedEditor) { newValue in
                        /// update active tab group only if the new one is not the same with it.
                        if let newValue, editorManager.activeEditor != newValue {
                            editorManager.activeEditor = newValue
                        }
                    }
                    .onChange(of: editorManager.activeEditor) { newValue in
                        if newValue != focusedEditor {
                            focusedEditor = newValue
                        }
                    }
                    .onChange(of: colorScheme) { newValue in
                        if matchAppearance {
                            themeModel.selectedTheme = newValue == .dark
                            ? themeModel.selectedDarkTheme
                            : themeModel.selectedLightTheme
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { output in
                        if let window = output.object as? NSWindow, self.window == window {
                            workspace.addToWorkspaceState(
                                key: .workspaceWindowSize,
                                value: NSStringFromRect(window.frame)
                            )
                        }
                    }
                }
            }
            .background(EffectView(.contentBackground))
        }
    }
}
