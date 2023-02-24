//
//  WorkspaceView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import AppKit

struct WorkspaceView: View {
    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    let tabBarHeight = 28.0
    private var path: String = ""

    @ObservedObject
    var workspace: WorkspaceDocument

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @Environment(\.window)
    private var window

    private var keybindings: KeybindingManager =  .shared

    @State
    private var showingAlert = false

    @State
    private var alertTitle = ""

    @State
    private var alertMsg = ""

    @State
    var showInspector = true

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            if workspace.workspaceClient != nil, let model = workspace.statusBarModel {
                ZStack {
                    EditorView(tabgroup: workspace.tabs, isBelowToolbar: true).id(UUID())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .safeAreaInset(edge: .top, spacing: 0) {
//                    VStack(spacing: 0) {
//                        TabBarView()
//                        TabBarBottomDivider()
//                    }
//                }
                .safeAreaInset(edge: .bottom) {
                    StatusBarView()
                        .environmentObject(model)
                }
            } else {
                EmptyView()
            }
        }
        .environmentObject(workspace)
        .background(EffectView(.contentBackground))
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button(
                action: { showingAlert = false },
                label: { Text("OK") }
            )
        }, message: { Text(alertMsg) })
        .onChange(of: workspace.selectionState.selectedId) { newValue in
            if newValue == nil {
                window.subtitle = ""
            }
        }
    }
}
