//
//  WorkspaceEditorView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI

struct WorkspaceEditorView: View {
    @State var text: String = ""
    @State var initialized = false
    var item: FileItem
    
    func initText(item: FileItem) {
        do {
            self.text = try String(contentsOf: item.url)
            self.initialized = true
        } catch let e {
            print("Failed to open \(e)")
        }
    }
    
    var body: some View {
        EditorView(text: $text)
            .navigationTitle(item.url.lastPathComponent)
            .onAppear(perform: { initText(item: self.item) })
            .onChange(of: item, perform: { newItem in
                self.initialized = false
                initText(item: newItem)
            })
            .onChange(of: text) { newValue in
                // TODO: save using Cmd-S shortcut or autosave
                if initialized {
                    do {
                        try newValue.write(to: item.url, atomically: true, encoding: .utf8)
                    } catch {}
                }
            }
    }
}
