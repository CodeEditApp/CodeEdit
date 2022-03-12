//
//  ContentView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI

struct MainContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text("CodeEdit")
                    .font(.title)
            }.padding()
           
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appDelegate: CodeEditorAppDelegate
    @SceneStorage("ContentView.path") private var path: String = ""
    
    @State private var queryString = ""
    
    private let items = ["One", "Two", "Three", "Four", "Five"]
    @State private var selection: String? = "home"

    var body: some View {
        NavigationView {
            sidebar
            
            Text("Location: \(path)")
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
            path = url.path
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if path == "" {
                    if let url = self.appDelegate.newProjectURL() {
                        self.path = url.path
                        
                        // TODO: additional project initialization
                    } else {
                        NSApplication.shared.keyWindow?.close()
                    }
                }
            }
        }
    }
    
    var sidebar: some View {
        VStack {
            List(selection: $selection) {
                NavigationLink(
                    destination: MainContentView()
                        .navigationTitle("Home")
                        .navigationSubtitle("Dashboard"),
                    label: {
                        Image(systemName: "house")
                            .foregroundColor(.secondary)
                        Text("Home")
                    }
                ).id("home")
                Section(header: Text("Items")) {
                    ForEach(items, id: \.self) { item in
                        NavigationLink(
                            destination: Text("Item \(item)")
                                .navigationTitle("Item \(item)"),
                            label: {
                                Image(systemName: "folder")
                                    .foregroundColor(.secondary)
                                Text("Item \(item)")
                            }
                        )
                    }
                }
            }
            .listStyle(SidebarListStyle())
        }
        .frame(minWidth: 250)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.leading")
                }
                .help("Show/Hide Sidebar")
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
