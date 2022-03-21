//
//  WorkspaceView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import WorkspaceClient

struct WorkspaceView: View {
    init(windowController: NSWindowController, workspace: WorkspaceDocument) {
        self.windowController = windowController
        self.workspace = workspace
    }

    var windowController: NSWindowController
    var tabBarHeight = 28.0
    private var path: String = ""

    @ObservedObject var workspace: WorkspaceDocument

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State var showInspector = true

    var body: some View {
        NavigationView {
            if workspace.workspaceClient != nil {
                NavigatorSidebar(workspace: workspace, windowController: windowController)
                    .frame(minWidth: 250)
                HSplitView {
                    WorkspaceCodeFileView(windowController: windowController,
                                    workspace: workspace)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
                  InspectorSidebar(workspace: workspace, windowController: windowController)
                  .toolbar {
                      RightToolBarItems(showInspector: $showInspector)
                  }
                  .frame(minWidth: 250, maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                EmptyView()
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button(
                action: { showingAlert = false },
                label: { Text("OK") }
            )
        }, message: { Text(alertMsg) })
        .onChange(of: workspace.selectedId) { newValue in
            if newValue == nil {
                windowController.window?.subtitle = ""
            }
        }
    }
}

struct RightToolBarItems: ToolbarContent {
    @Binding var showInspector: Bool
    var body: some ToolbarContent {
        ToolbarItem(content: { Spacer() } )
        ToolbarItem(placement: .primaryAction) {
            Button(action: { showInspector.toggle() }) {
                Label("Toggle Inspector", systemImage: "sidebar.right")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView(windowController: NSWindowController(), workspace: .init())
    }
}
