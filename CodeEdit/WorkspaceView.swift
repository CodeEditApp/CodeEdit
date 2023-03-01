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

    @State var terminalCollapsed = false

    @State
    private var searchText = ""

    var body: some View {
        ZStack {
            if workspace.workspaceClient != nil, let model = workspace.statusBarModel {
                VStack {
                    SplitViewReader { proxy in
                        SplitView(axis: .vertical) {

                            EditorView(tabgroup: workspace.tabs)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .safeAreaInset(edge: .bottom, spacing: 0) {
                                    StatusBarView(proxy: proxy, collapsed: $terminalCollapsed)
                                }
                                .layoutPriority(2)

                            VStack {
                                TerminalEmulatorView(url: model.workspaceURL)
                                    .background {
                                        if colorScheme == .dark {
                                            if prefs.preferences.theme.selectedTheme == prefs.preferences.theme.selectedLightTheme {
                                                Color.white
                                            } else {
                                                EffectView(.underPageBackground)
                                            }
                                        } else {
                                            if prefs.preferences.theme.selectedTheme == prefs.preferences.theme.selectedDarkTheme {
                                                Color.black
                                            } else {
                                                EffectView(.contentBackground)
                                            }
                                        }
                                    }
                                HStack(alignment: .center, spacing: 10) {
                                    FilterTextField(title: "Filter", text: $searchText)
                                        .frame(maxWidth: 300)
                                    Spacer()
                                    StatusBarClearButton()
                                    Divider()
                                    StatusBarSplitTerminalButton()
                                    StatusBarMaximizeButton()
                                }
                                .padding(10)
                                .frame(maxHeight: 29)
                                .background(.bar)
                            }
                            .id(StatusBarView.statusbarID)
                            .collapsable()
                            .collapsed($terminalCollapsed)
                            .frame(minHeight: 200, maxHeight: 400)
                            .layoutPriority(1)
                        }
                        .edgesIgnoringSafeArea(.top)
                        .environmentObject(model)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
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
