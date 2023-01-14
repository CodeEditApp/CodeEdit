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

    /// The fullscreen state of the NSWindow.
    /// This will be passed into all child views as an environment variable.
    @State
    var isFullscreen = false

    @State
    private var enterFullscreenObserver: Any?

    @State
    private var leaveFullscreenObserver: Any?

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
        .onAppear {
            // There may be other methods to monitor the full-screen state.
            // But I cannot find a better one for now because I need to pass this into the SwiftUI.
            // And it should always be updated.
            enterFullscreenObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.didEnterFullScreenNotification,
                object: nil,
                queue: .current,
                using: { _ in self.isFullscreen = true }
            )
            leaveFullscreenObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.willExitFullScreenNotification,
                object: nil,
                queue: .current,
                using: { _ in self.isFullscreen = false }
            )
        }
        .onDisappear {
            // Unregister the observer when the view is going to disappear.
            if enterFullscreenObserver != nil {
                NotificationCenter.default.removeObserver(enterFullscreenObserver!)
            }
            if leaveFullscreenObserver != nil {
                NotificationCenter.default.removeObserver(leaveFullscreenObserver!)
            }
        }
        // Send the environment to all subviews.
        .environment(\.isFullscreen, self.isFullscreen)
        // When tab bar style is changed, update NSWindow configuration as follows.
        .onChange(of: prefs.preferences.general.tabBarStyle) { newStyle in
            DispatchQueue.main.async {
                if newStyle == .native {
                    window.titlebarAppearsTransparent = true
                    window.titlebarSeparatorStyle = .none
                } else {
                    window.titlebarAppearsTransparent = false
                    window.titlebarSeparatorStyle = .automatic
                }
            }
        }
    }
}
