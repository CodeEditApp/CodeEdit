//
//  ContentView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI

struct ContentView: View {
    @State var workspace: Workspace?
    @State var selectedId: UUID?
    @State var openFileItems: [FileItem] = []
    @State var urlInit = false
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    
    var tabBarHeight = 28.0
    
    @EnvironmentObject var appDelegate: CodeEditorAppDelegate
    @SceneStorage("ContentView.path") private var path: String = ""
    
    func closeFileTab(item: FileItem) {
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
            if let workspace = workspace {
                sidebar
                    .frame(minWidth: 250)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: toggleSidebar) {
                                Image(systemName: "sidebar.leading")
                            }
                            .help("Show/Hide Sidebar")
                        }
                    }
                
                if openFileItems.isEmpty {
                    Text("Open file from sidebar")
                } else {
                    ZStack {
                        if let selectedId = selectedId {
                            if let selectedItem = workspace.getFileItem(id: selectedId) {
                                WorkspaceEditorView(item: selectedItem)
                            }
                        }
                        
                        VStack {
                            tabBar
                                .frame(maxHeight: tabBarHeight)
                                .background {
                                    BlurView(material: .titlebar, blendingMode: .withinWindow)
                                }
                            
                            Spacer()
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                }
                .help("Back")
            }
            ToolbarItem(placement: .navigation) {
                Button(action: {}){
                    Image(systemName: "chevron.right")
                }
                .disabled(true)
                .help("Forward")
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onOpenURL { url in
            urlInit = true
            do {
                self.workspace = try Workspace(folderURL: url)
            } catch {
                self.alertTitle = "Unable to Open Workspace"
                self.alertMsg = error.localizedDescription
                self.showingAlert = true
                print(error.localizedDescription)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if !self.urlInit {
                    if let url = self.appDelegate.newProjectURL() {
                        do {
                            self.workspace = try Workspace(folderURL: url)
                        } catch {
                            self.alertTitle = "Unable to Open Folder"
                            self.alertMsg = error.localizedDescription
                            self.showingAlert = true
                            print(error.localizedDescription)
                            NSApplication.shared.keyWindow?.close()
                        }
                        
                        // TODO: additional project initialization
                    } else {
                        NSApplication.shared.keyWindow?.close()
                    }
                }
            }
        }
        .alert(alertTitle, isPresented: $showingAlert, actions: {
            Button(action: { showingAlert = false }) {
                Text("OK")
            }
        }, message: { Text(alertMsg) })
    }
    
    var tabBar: some View {
        VStack(spacing: 0.0) {
            Divider()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0.0) {
                    Divider()
                        .foregroundColor(.primary.opacity(0.25))
                    
                    ForEach(openFileItems, id: \.id) { item in
                        let isActive = selectedId == item.id
                        
                        HStack(spacing: 0.0) {
                            Button(action: { selectedId = item.id }) {
                                FileTabRow(fileItem: item, closeAction: {
                                    withAnimation {
                                        closeFileTab(item: item)
                                    }
                                })
                                .frame(height: tabBarHeight)
                                .foregroundColor(.primary.opacity(isActive ? 0.9 : 0.55))
                            }
                            .buttonStyle(.plain)
                            .background {
                                (isActive ? Color(red: 0.219, green: 0.219, blue: 0.219) : Color(red: 0.113, green: 0.113, blue: 0.113))
                                    .opacity(0.85)
                            }
                            
                            Divider()
                                .foregroundColor(.primary.opacity(0.25))
                        }
                        .animation(.easeOut(duration: 0.15), value: openFileItems)
                    }
                    
                    Spacer()
                }
            }
            
            Divider()
        }
    }
    
    var sidebar: some View {
        List {
            Section(header: Text(workspace!.directoryURL.lastPathComponent)) {
                OutlineGroup(workspace!.fileItems, children: \.children) { item in
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
    
    private func toggleSidebar() {
        #if os(iOS)
        #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

