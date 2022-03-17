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
    @ObservedObject var workspace: WorkspaceDocument
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    
    var tabBarHeight = 28.0

    private var path: String = ""

    var body: some View {
        NavigationView {
            if workspace.workspaceClient != nil {
                SideBar(workspace: workspace, windowController: windowController)
                    .frame(minWidth: 250)
                
                Text("Open file from sidebar")
            } else {
                EmptyView()
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button(action: { showingAlert = false }) {
                Text("OK")
            }
        }, message: { Text(alertMsg) })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView(windowController: NSWindowController(), workspace: .init())
    }
}

