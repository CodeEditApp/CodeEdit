//
//  ContentView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import WorkspaceClient

struct ContentView: View {
    @State private var directoryURL: URL?
    @State private var workspaceClient: WorkspaceClient?

	// TODO: Create a ViewModel to hold selectedId, openFileItems, ... to pass it to subviews as an EnvironmentObject (less boilerplate parameters)
    @State var selectedId: UUID?
    @State var openFileItems: [WorkspaceClient.FileItem] = []
    @State var urlInit = false
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    
    @EnvironmentObject var appDelegate: CodeEditorAppDelegate
    @SceneStorage("ContentView.path") private var path: String = ""
    
    private let ignoredFilesAndDirectory = [
        ".DS_Store",
    ]
    
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
            if let workspaceClient = workspaceClient, let directoryURL = directoryURL {
				SideBar(directoryURL: directoryURL,
						workspaceClient: workspaceClient,
						openFileItems: $openFileItems,
						selectedId: $selectedId)
                    .frame(minWidth: 250)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: toggleSidebar) {
                                Image(systemName: "sidebar.leading").imageScale(.large)
                            }
                            .help("Show/Hide Sidebar")
                        }
                    }
                
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
                            TabBar(openFileItems: $openFileItems, selectedId: $selectedId)

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
                    Image(systemName: "chevron.left").imageScale(.large)
                }
                .help("Back")
            }
            ToolbarItem(placement: .navigation) {
                Button(action: {}){
                    Image(systemName: "chevron.right").imageScale(.large)
                }
                .disabled(true)
                .help("Forward")
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onOpenURL { url in
            urlInit = true
            do {
                self.workspaceClient = try .default(
                    fileManager: .default,
                    folderURL: url,
                    ignoredFilesAndFolders: ignoredFilesAndDirectory
                )
                self.directoryURL = url
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
                            self.directoryURL = url
                            self.workspaceClient = try .default(
                                fileManager: .default,
                                folderURL: url,
                                ignoredFilesAndFolders: ignoredFilesAndDirectory
                            )
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

