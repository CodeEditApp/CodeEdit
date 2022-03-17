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
            if let workspaceClient = workspace.workspaceClient {
                sidebar(workspaceClient: workspaceClient)
                    .frame(minWidth: 250)
                
                if !workspace.openFileItems.isEmpty, let selectedId = workspace.selectedId,
                   let selectedItem = try? workspaceClient.getFileItem(selectedId) {
                    WorkspaceEditorView(workspace: workspace, item: selectedItem, windowController: windowController)
                        .safeAreaInset(edge: .top) {
                            tabBar
                                .frame(maxHeight: tabBarHeight)
                                .background(Material.regular)
                        }
                } else {
                    Text("Open file from sidebar")
                }
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
        .onChange(of: self.workspace.selectedId) { n in
            if n == nil {
                self.windowController.window?.subtitle = ""
            }
            guard let item = self.workspace.openFileItems.first(where: { item in
                return item.id == self.workspace.selectedId
            }) else { return }
            self.windowController.window?.subtitle = item.url.lastPathComponent
        }
    }
    
    func tabRow(item: WorkspaceClient.FileItem, isActive: Bool) -> some View {
        HStack(spacing: 0.0) {
            FileTabRow(fileItem: item, isSelected: isActive) {
                withAnimation {
                    workspace.closeFileTab(item: item)
                }
            }
            
            Divider()
        }
        .frame(height: tabBarHeight)
        .foregroundColor(isActive ? .primary : .gray)
    }
    
    var tabBar: some View {
        VStack(spacing: 0.0) {
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { value in
                    HStack(alignment: .center, spacing: 0.0) {
                        ForEach(workspace.openFileItems, id: \.id) { item in
                            let isActive = workspace.selectedId == item.id
                            
                            Button(action: { workspace.selectedId = item.id }) {
                                if isActive {
                                    tabRow(item: item, isActive: isActive)
                                        .background(Material.bar)
                                } else {
                                    tabRow(item: item, isActive: isActive)
                                }
                                
                            }
                            .animation(.easeOut(duration: 0.2), value: workspace.openFileItems)
                            .buttonStyle(.plain)
                            .id(item.id)
                        }
                    }
                    .onChange(of: workspace.selectedId) { newValue in
                        withAnimation {
                            value.scrollTo(newValue)
                        }
                    }
                }
            }
            
            Divider()
                .foregroundColor(.gray)
                .frame(height: 1.0)
        }
    }
    
    func sidebar(
        workspaceClient: WorkspaceClient
    ) -> some View {
        List {
            Section(header: Text(workspace.fileURL?.lastPathComponent ?? "Unknown Workspace")) {
                OutlineGroup(workspaceClient.getFiles(), children: \.children) { item in
                    if item.children == nil {
                        // TODO: Add selection indicator
                        Button(action: {
                            workspace.openFile(item: item)
                        }) {
                            Label(item.url.lastPathComponent, systemImage: item.systemImage)
                                .accentColor(.secondary)
                                .font(.callout)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Label(item.url.lastPathComponent, systemImage: item.systemImage)
                            .accentColor(.secondary)
                            .font(.callout)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView(windowController: NSWindowController(), workspace: .init())
    }
}

