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
    @State private var queryString = ""
    
    private let items = ["One", "Two", "Three", "Four", "Five"]
    @State private var selection: String? = "home"

    var body: some View {
        NavigationView {
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

            .toolbar {
            ToolbarItem(placement: .automatic) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.leading")
                    }).help("Show/Hide Sidebar")
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "chevron.left")
                    }).help("Back")
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "chevron.right")
                    }).disabled(true).help("Fordward")
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
