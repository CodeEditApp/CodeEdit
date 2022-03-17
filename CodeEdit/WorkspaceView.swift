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
    
    @State var selectedId: UUID?
    @State var openFileItems: [WorkspaceClient.FileItem] = []
    @State var urlInit = false
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    
    var tabBarHeight = 28.0

    private var path: String = ""
    
    func closeFileTab(item: WorkspaceClient.FileItem) {
        guard let idx = openFileItems.firstIndex(of: item) else { return }
        let closedFileItem = openFileItems.remove(at: idx)
        guard closedFileItem.id == selectedId else { return }
        
        if openFileItems.isEmpty {
            selectedId = nil
        } else if idx == 0 {
            selectedId = openFileItems.first?.id
        } else {
            selectedId = openFileItems[idx - 1].id
        }
    }

    var body: some View {
        NavigationView {
            if let workspaceClient = workspace.workspaceClient {
                sidebar(workspaceClient: workspaceClient)
                    .frame(minWidth: 250)
                
                if openFileItems.isEmpty {
                    Text("Open file from sidebar")
                } else {
                    ZStack {
                        if let selectedId = selectedId {
                            if let selectedItem = try? workspaceClient.getFileItem(selectedId) {
                                WorkspaceEditorView(item: selectedItem)
                            }
                        }
                        
                        VStack {
                            tabBar
                                .frame(maxHeight: tabBarHeight)
                                .background(Material.regular)
                            
                            Spacer()
                        }
                    }
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
    }
    
    func tabRow(item: WorkspaceClient.FileItem, isActive: Bool) -> some View {
        HStack(spacing: 0.0) {
            FileTabRow(fileItem: item, isSelected: isActive) {
                withAnimation {
                    closeFileTab(item: item)
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
                        ForEach(openFileItems, id: \.id) { item in
                            let isActive = selectedId == item.id
                            
                            Button(action: { selectedId = item.id }) {
                                if isActive {
                                    tabRow(item: item, isActive: isActive)
                                        .background(Material.bar)
                                } else {
                                    tabRow(item: item, isActive: isActive)
                                }
                                
                            }
                            .animation(.easeOut(duration: 0.2), value: openFileItems)
                            .buttonStyle(.plain)
                            .id(item.id)
                        }
                    }
                    .onChange(of: selectedId) { newValue in
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
                            withAnimation {
                                if !openFileItems.contains(item) { openFileItems.append(item) }
                            }
                            selectedId = item.id
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

