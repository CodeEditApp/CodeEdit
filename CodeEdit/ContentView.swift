//
//  ContentView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/10/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct CodeFile: FileDocument {
    
    static var readableContentTypes = [UTType.sourceCode]
    var text = ""
    
    init(initialText: String = "") {
        self.text = initialText
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
    
}

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
    @State var workspaceDirectoryURL: URL?
    
    var currentDocument: Binding<CodeFile>?
    
    func openFolderDialog() {
        let dialog = NSOpenPanel()
        
        dialog.title = "Select a Folder to Open"
        dialog.allowsMultipleSelection = false
        dialog.canChooseFiles = false
        dialog.canChooseDirectories = true
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            if let result = dialog.url {
                workspaceDirectoryURL = result
                print("Openned directory: \(result.path)")
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                if let folderURL = workspaceDirectoryURL {
                    Section(header: Text(folderURL.lastPathComponent)) {
                        Text("Folder 1")
                        Text("Folder 2")
                        Text("Folder 3")
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
                    .buttonStyle(.borderless)
                    .padding(.vertical, 8.0)
                    .background {
                        RoundedRectangle(cornerRadius: 10.0)
                            .foregroundColor(.blue)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            
            if currentDocument != nil {
                TextEditor(text: currentDocument!.text)
            }
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
