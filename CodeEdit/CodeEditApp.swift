//
//  CodeEditApp.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI
import WindowManagement

struct WindowSplitView: View {
    @StateObject var workspace: WorkspaceDocument
    @State var visibility: NavigationSplitViewVisibility = .all
    @State var showInspector = true
    @State var window: NSWindow = .init()

    var body: some View {
        WindowObserver(window: window) {
            NavigationSplitView(columnVisibility: $visibility) {
                NavigatorSidebarView(workspace: workspace)
                    .toolbar {
                        ToolbarItem {
                            Button {
                                withAnimation(.linear(duration: 0)) {
                                    if visibility == .detailOnly {
                                        visibility = .all
                                    } else {
                                        visibility = .detailOnly
                                    }
                                }
                            } label: {
                                Image(systemName: "sidebar.left")
                                    .imageScale(.large)
                            }
                        }
                    }
            } detail: {
                if #available(macOS 14.0, *) {
                    WorkspaceView()
                        .toolbar {
                            ToolbarItem(id: "com.apple.SwiftUI.navigationSplitView.toggleSidebar") {
                                ToolbarBranchPicker(
                                    shellClient: currentWorld.shellClient,
                                    workspaceFileManager: workspace.workspaceFileManager
                                )
                            }
                            .defaultCustomization(.hidden, options: [])
                        }
                        .inspector(isPresented: $showInspector) {
                            InspectorSidebarView()
                                .inspectorColumnWidth(min: 100, ideal: 200, max: 400)
                                .toolbar {
                                    Spacer()
                                    Button {
                                        showInspector.toggle()
                                    } label: {
                                        Image(systemName: "sidebar.right")
                                            .imageScale(.large)
                                    }
                                }
                        }
                } else {
                    WorkspaceView()
                }
            }
        }
        .environmentObject(workspace)
        .environmentObject(workspace.tabManager)
        .environmentObject(workspace.debugAreaModel)
        .task {
            if let newWindow = workspace.windowControllers.first?.window {
                window = newWindow
            }
        }
    }
}

@main
struct CodeEditApp: App {
    @NSApplicationDelegateAdaptor var appdelegate: AppDelegate
    @ObservedObject var settings = Settings.shared

    @Environment(\.openWindow) var openWindow

    let updater: SoftwareUpdater = SoftwareUpdater()

    init() {
        _ = CodeEditDocumentController.shared
        NSMenuItem.swizzle()
        NSSplitViewItem.swizzle()
    }

    var body: some Scene {
        Group {
            WelcomeWindow()
                .keyboardShortcut("1", modifiers: [.command, .shift])

            ExtensionManagerWindow()
                .keyboardShortcut("2", modifiers: [.command, .shift])

            AboutWindow()

            SettingsWindow()

            NSDocumentGroup(for: WorkspaceDocument.self) { workspace in
//                WindowObserver(window: workspace.windowControllers.first!.window!) {
                    WindowSplitView(workspace: workspace)
                        .injectWindow(.document(WorkspaceDocument.self))
//                }

            } defaultAction: {
                openWindow(id: SceneID.welcome.rawValue)
            }
            .register(.document(WorkspaceDocument.self))
            .transition(.documentWindow)
            .windowToolbarStyle(.unifiedCompact(showsTitle: false))
            .enableOpenWindow()
            .commands {
                CodeEditCommands()
            }
        }
        .environment(\.settings, settings.preferences) // Add settings to each window environment
    }
}
