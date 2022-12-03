//
//  WorkspaceView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import AppKit

struct WorkspaceView: View {
    init(windowController: NSWindowController, workspace: WorkspaceDocument) {
        self.windowController = windowController
        self.workspace = workspace
    }

    let windowController: NSWindowController
    let tabBarHeight = 28.0
    private var path: String = ""

    @ObservedObject
    var workspace: WorkspaceDocument

    @StateObject
    private var prefs: AppPreferencesModel = .shared

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
                WorkspaceCodeFileView(windowController: windowController, workspace: workspace)
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
                    .background {
                        if prefs.preferences.general.tabBarStyle == .xcode {
                            // Use the same background material as xcode tab bar style.
                            // Only when the tab bar style is set to `xcode`.
                            TabBarXcodeBackground()
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            TabBar(windowController: windowController, workspace: workspace)
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
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button(
                action: { showingAlert = false },
                label: { Text("OK") }
            )
        }, message: { Text(alertMsg) })
        .onChange(of: workspace.selectionState.selectedId) { newValue in
            if newValue == nil {
                windowController.window?.subtitle = ""
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
                    windowController.window?.titlebarAppearsTransparent = true
                    windowController.window?.titlebarSeparatorStyle = .none
                } else {
                    windowController.window?.titlebarAppearsTransparent = false
                    windowController.window?.titlebarSeparatorStyle = .automatic
                }
            }
        }
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView(windowController: NSWindowController(), workspace: .init())
    }
}

private struct WorkspaceFullscreenStateEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isFullscreen: Bool {
        get { self[WorkspaceFullscreenStateEnvironmentKey.self] }
        set { self[WorkspaceFullscreenStateEnvironmentKey.self] = newValue }
    }
}
