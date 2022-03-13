//
//  ContentView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI

struct WorkspaceView: View {
    @ObservedObject var workspace: Workspace
    
    @State var selectedId: UUID?
    @State var urlInit = false
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    
    @SceneStorage("ContentView.path") private var path: String = ""

    var body: some View {
        NavigationView {
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
            
            Text("Open file from sidebar")
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
    }
    
    var sidebar: some View {
        List {
            Section(header: Text(workspace.fileURL?.lastPathComponent ?? "Not saved")) {
                OutlineGroup(workspace.fileItems, children: \.children) { item in
                    if item.children == nil {
                        NavigationLink(tag: item.id, selection: $selectedId) {
                            WorkspaceEditorView(item: item)
                        } label: {
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
