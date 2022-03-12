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
    @State var workspace: Workspace?
    @Binding var currentDocument: CodeFile
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    
    func openFolderDialog() {
        let dialog = NSOpenPanel()
        
        dialog.title = "Select a Folder to Open"
        dialog.allowsMultipleSelection = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let result = dialog.url {
                do {
                    workspace = try Workspace(folderURL: result)
                } catch {
                    alertTitle = "Unable to Open Folder"
                    alertMsg = error.localizedDescription
                    showingAlert = true
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func openFileEditor(_ url: URL) {
        // TODO: Create and load a `CodeFile` instance from the file URL
        // ^ I can't seem to figure this one out
        print("Opening file \(url.path)")
    }
    
    var sidebar: some View {
        List {
            if let workspace = workspace {
                Section(header: Text(workspace.directoryURL.lastPathComponent)) {
                    OutlineGroup(workspace.fileItems, children: \.children) { item in
                        if item.children == nil {
                            Button(action: { openFileEditor(item.url) }) {
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
            } else {
                Button(action: openFolderDialog) {
                    HStack {
                        Spacer()
                        
                        Text("Open Folder")
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .padding(.vertical, 10.0)
                .background {
                    RoundedRectangle(cornerRadius: 10.0)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(minWidth: 250)
        .listStyle(.sidebar)
    }

    var body: some View {
        NavigationView {
            sidebar
            TextEditor(text: $currentDocument.text)
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
        // This alert system could probably be improved
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
        ContentView(currentDocument: .constant(CodeFile(initialText: "Hello, World!")))
    }
}
