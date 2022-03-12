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
    @Binding var document: CodeFile

    var body: some View {
        NavigationView {
            List {
                Text("Folder 1")
                Text("Folder 2")
                Text("Folder 3")
            }
            .listStyle(SidebarListStyle())
            
            TextEditor(text: $document.text)
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
        ContentView(document: .constant(CodeFile()))
    }
}
