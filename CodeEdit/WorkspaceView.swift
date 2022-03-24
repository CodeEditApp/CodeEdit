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
//                NavigatorSidebar(workspace: workspace, windowController: windowController)
                    .frame(minWidth: 250)
                WorkspaceCodeFileView(windowController: windowController,
                                      workspace: workspace)
            } else {
                EmptyView()
            }
        }
        .frame(minWidth: 1000, minHeight: 600)
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
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView(windowController: NSWindowController(), workspace: .init())
    }
}
