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
    
    @EnvironmentObject var appDelegate: CodeEditorAppDelegate
    @SceneStorage("ContentView.path") private var path: String = ""

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
                
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            ForEach(openFileItems, id: \.id) { item in
                                Button(action: { selectedId = item.id }) {
                                    Label(item.url.lastPathComponent, systemImage: item.systemImage)
                                        .font(.headline)
                                        .padding(.horizontal, 15.0)
                                        .padding(.vertical, 8.0)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            Spacer()
                        }
                    }
                    .frame(maxHeight: 30)
                    
                    Divider()
                    
                    if openFileItems.isEmpty {
                        Text("Open file from sidebar")
                    } else {
                        if let selectedId = selectedId {
                            if let selectedItem = workspace.getFileItem(id: selectedId) {
                                WorkspaceEditorView(item: selectedItem)
                            }
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
    
    var sidebar: some View {
        List {
            Section(header: Text(workspace!.directoryURL.lastPathComponent)) {
                OutlineGroup(workspace!.fileItems, children: \.children) { item in
                    if item.children == nil {
//                        NavigationLink(tag: item.id, selection: $selectedId) {
//                            WorkspaceEditorView(item: item)
//                        } label: {
//                            Label(item.url.lastPathComponent, systemImage: item.systemImage)
//                                .accentColor(.secondary)
//                                .font(.callout)
//                        }
                        
                        Button(action: {
                            if !openFileItems.contains(item) { openFileItems.append(item) }
                            selectedId = item.id
                        }) {
                            Label(item.url.lastPathComponent, systemImage: item.systemImage)
                                .accentColor(.secondary)
                                .font(.callout)
                        }
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
        ContentView(openFileItems: [
            FileItem(url: URL(string: "code.swift")!),
            FileItem(url: URL(string: "program.py")!),
            FileItem(url: URL(string: "index.html")!)
        ])
    }
}

