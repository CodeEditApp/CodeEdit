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

    @EnvironmentObject
    private var workspace: WorkspaceDocument

    @EnvironmentObject
    private var tabManager: TabManager

    @Environment(\.window)
    private var window

    private var keybindings: KeybindingManager =  .shared

    @State
    private var showingAlert = false

    @Environment(\.colorScheme)
    private var colorScheme

    @State
    private var terminalCollapsed = true

    @FocusState
    var focusedEditor: TabGroupData?

    var body: some View {
        if workspace.workspaceFileManager != nil {
            VStack {
                SplitViewReader { proxy in
                    SplitView(axis: .vertical) {

                        EditorView(tabgroup: tabManager.tabGroups, focus: $focusedEditor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .safeAreaInset(edge: .bottom, spacing: 0) {
                                StatusBarView(proxy: proxy, collapsed: $terminalCollapsed)
                            }

                        StatusBarDrawer()
                            .collapsable()
                            .collapsed($terminalCollapsed)
                            .holdingPriority(.init(20))
                            .frame(minHeight: 200, maxHeight: 400)
                            .frame(maxWidth: .infinity)
                    }
                    .edgesIgnoringSafeArea(.top)
                    .environmentObject(workspace.statusBarModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: focusedEditor) { newValue in
                        if let newValue {
                            tabManager.activeTabGroup = newValue
                        }
                    }
                    .onChange(of: tabManager.activeTabGroup) { newValue in
                        if newValue != focusedEditor {
                            focusedEditor = newValue
                        }
                    }

                }
            }
            .background(EffectView(.contentBackground))
        }
    }
}
