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

    var noEditor: some View {
        Text("No Editor")
            .font(.system(size: 17))
            .foregroundColor(.secondary)
            .frame(minHeight: 0)
            .clipped()
    }

    @ViewBuilder var tabContent: some View {
        if let tabID = workspace.selectionState.selectedId {
            switch tabID {
            case .codeEditor:
                WorkspaceCodeFileView(workspace: workspace)
            case .extensionInstallation:
                if let plugin = workspace.selectionState.selected as? Plugin {
                    ExtensionInstallationView(plugin: plugin)
                        .environmentObject(workspace)
                        .frame(alignment: .center)
                }
            }
        } else {
            noEditor
        }
    }

    var body: some View {
        ZStack {
            if workspace.workspaceClient != nil, let model = workspace.statusBarModel {
                ZStack {
                    tabContent
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        TabBarView(workspace: workspace)
                        TabBarBottomDivider()
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    StatusBarView(model: model)
                }
            } else {
                EmptyView()
            }
        }
        .background(colorScheme == .dark ? Color(.black).opacity(0.25) : Color(.white))
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
