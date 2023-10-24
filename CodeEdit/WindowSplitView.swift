//
//  WindowSplitView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 18/06/2023.
//
//

import SwiftUI

struct WindowSplitView: View {
    @StateObject var workspace: WorkspaceDocument
    @State var visibility: NavigationSplitViewVisibility = .all
    @State var showInspector = true
    @State var window: NSWindow = .init()

    var navigatorAreaView: some View {
        NavigatorAreaView(workspace: workspace, viewModel: NavigatorSidebarViewModel())
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
    }

    var body: some View {
        WindowObserver(window: window) {
            if #available(macOS 14.0, *) {
                NavigationSplitView(columnVisibility: $visibility) {
                    navigatorAreaView
                } detail: {
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
                }
#if swift(>=5.9) // Fixes build on Xcode 14
                .inspector(isPresented: $showInspector) {
                    InspectorAreaView(viewModel: InspectorAreaViewModel())
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
#endif
            } else {
                NavigationSplitView(columnVisibility: $visibility) {
                    navigatorAreaView
                } detail: {
                    WorkspaceView()
                }
            }
        }
        .focusedSceneValue(\.navigationSplitViewVisibility, $visibility)
        .focusedSceneValue(\.inspectorVisibility, $showInspector)
        .environmentObject(workspace)
        .environmentObject(workspace.editorManager)
        .environmentObject(workspace.utilityAreaModel)
        .task {
            if let newWindow = workspace.windowControllers.first?.window {
                window = newWindow
            }
        }
    }
}
