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
    var workspace: WorkspaceDocument

    @EnvironmentObject private var tabManager: TabManager

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @Environment(\.window)
    private var window

    private var keybindings: KeybindingManager =  .shared

    @State
    private var showingAlert = false

    @Environment(\.colorScheme) var colorScheme

    @State var terminalCollapsed = true

    @FocusState var focusedEditor: TabGroupData?

    var body: some View {
        if workspace.workspaceClient != nil {
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
                            .frame(minHeight: 200, maxHeight: 400)

                    }
                    .edgesIgnoringSafeArea(.top)
                    .environmentObject(workspace.statusBarModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: focusedEditor) { newValue in
                        if let newValue {
                            tabManager.activeTabGroup = newValue
                        } else {
                            print("No Editor has focus")
                        }
                    }
                }
            }
        }
    }
}
