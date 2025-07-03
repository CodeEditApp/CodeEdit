//
//  WorkspaceView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct WorkspaceView: View {
    @Environment(\.window.value)
    private var window: NSWindow?

    @Environment(\.colorScheme)
    private var colorScheme

    @FocusState var focusedEditor: Editor?

    @AppSettings(\.theme.matchAppearance)
    var matchAppearance

    @AppSettings(\.sourceControl.general.sourceControlIsEnabled)
    var sourceControlIsEnabled

    @EnvironmentObject private var workspace: WorkspaceDocument
    @EnvironmentObject private var editorManager: EditorManager
    @EnvironmentObject private var utilityAreaViewModel: UtilityAreaViewModel

    @StateObject private var themeModel: ThemeModel = .shared

    @State private var showingAlert = false
    @State private var terminalCollapsed = true
    @State private var editorCollapsed = false
    @State private var editorsHeight: CGFloat = 0
    @State private var drawerHeight: CGFloat = 0

    private let statusbarHeight: CGFloat = 29

    private var keybindings: KeybindingManager =  .shared

    var body: some View {
        if workspace.workspaceFileManager != nil, let sourceControlManager = workspace.sourceControlManager {
            VStack {
                SplitViewReader { proxy in
                    SplitView(axis: .vertical) {
                        editorArea
                        utilityAreaPlaceholder
                    }
                    .edgesIgnoringSafeArea(.top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .top) {
                        utilityArea(proxy: proxy)
                    }
                    .overlay(alignment: .topTrailing) {
                        NotificationPanelView()
                    }

                    // MARK: - Tab Focus Listeners

                    .onChange(of: editorManager.activeEditor) { newValue in
                        focusedEditor = newValue
                    }
                    .onChange(of: focusedEditor) { newValue in
                        /// Update active tab group only if the new one is not the same with it.
                        if let newValue, editorManager.activeEditor != newValue {
                            editorManager.activeEditor = newValue
                        }
                    }

                    // MARK: - Theme Color Scheme

                    .task {
                        themeModel.colorScheme = colorScheme
                    }
                    .onChange(of: colorScheme) { newValue in
                        themeModel.colorScheme = newValue
                        if matchAppearance {
                            themeModel.selectedTheme = newValue == .dark
                            ? themeModel.selectedDarkTheme
                            : themeModel.selectedLightTheme
                        }
                    }

                    // MARK: - Source Control

                    .task {
                        do {
                            try await sourceControlManager.refreshRemotes()
                            try await sourceControlManager.refreshStashEntries()
                        } catch {
                            await sourceControlManager.showAlertForError(
                                title: "Error refreshing Git data",
                                error: error
                            )
                        }
                    }
                    .onChange(of: sourceControlIsEnabled) { newValue in
                        if newValue {
                            Task {
                                await sourceControlManager.refreshCurrentBranch()
                            }
                        } else {
                            sourceControlManager.currentBranch = nil
                        }
                    }

                    // MARK: - Window Will Close

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
            .background(WorkspaceSheets().environmentObject(sourceControlManager))
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                _ = handleDrop(providers: providers)
                return true
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("workspace area")
        }
    }

    // MARK: - Editor Area

    @ViewBuilder private var editorArea: some View {
        ZStack {
            GeometryReader { geo in
                EditorLayoutView(
                    layout: editorManager.isFocusingActiveEditor
                    ? editorManager.activeEditor.getEditorLayout() ?? editorManager.editorLayout
                    : editorManager.editorLayout,
                    focus: $focusedEditor
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: geo.size.height) { newHeight in
                    editorsHeight = newHeight
                }
                .onAppear {
                    editorsHeight = geo.size.height
                }
            }
        }
        .frame(minHeight: 170 + 29 + 29)
        .collapsable()
        .collapsed($utilityAreaViewModel.isMaximized)
        .holdingPriority(.init(1))
    }

    // MARK: - Utility Area

    @ViewBuilder
    private func utilityArea(proxy: SplitViewProxy) -> some View {
        ZStack(alignment: .top) {
            UtilityAreaView()
                .frame(height: utilityAreaViewModel.isMaximized ? nil : drawerHeight)
                .frame(maxHeight: utilityAreaViewModel.isMaximized ? .infinity : nil)
                .padding(.top, utilityAreaViewModel.isMaximized ? statusbarHeight + 1 : 0)
                .offset(y: utilityAreaViewModel.isMaximized ? 0 : editorsHeight + 1)
            VStack(spacing: 0) {
                StatusBarView(proxy: proxy)
                if utilityAreaViewModel.isMaximized {
                    PanelDivider()
                }
            }
            .offset(y: utilityAreaViewModel.isMaximized ? 0 : editorsHeight - statusbarHeight)
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder private var utilityAreaPlaceholder: some View {
        Rectangle()
            .collapsable()
            .collapsed($utilityAreaViewModel.isCollapsed)
            .splitViewCanAnimate($utilityAreaViewModel.animateCollapse)
            .opacity(0)
            .frame(idealHeight: 260)
            .frame(minHeight: 100)
            .background {
                GeometryReader { geo in
                    Rectangle()
                        .opacity(0)
                        .onChange(of: geo.size.height) { newHeight in
                            drawerHeight = newHeight
                        }
                        .onAppear {
                            drawerHeight = geo.size.height
                        }
                }
            }
            .accessibilityHidden(true)
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
                    editorManager.activeEditor.openTab(file: file)
                }
            }
        }
        return true
    }
}
