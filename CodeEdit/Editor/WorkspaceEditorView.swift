//
//  WorkspaceEditorView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI
import WorkspaceClient

struct WorkspaceEditorView: View {
    @State var text: String = ""
    @State var initialized = false
    var item: WorkspaceClient.FileItem
    
    func initText(item: WorkspaceClient.FileItem) {
        do {
            self.text = try String(contentsOf: item.url)
            self.initialized = true
        } catch let e {
            print("Failed to open \(e)")
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                EditorView(text: $text)
                    .frame(minHeight: proxy.size.height + 30.0)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 30.0)
                    .padding(.bottom, 200.0)
                    .background(Color(nsColor: NSColor.textBackgroundColor))
            }
        }
            .navigationTitle(item.url.lastPathComponent)
            .onAppear { initText(item: self.item) }
            .onChange(of: item) { newItem in
                self.initialized = false
                initText(item: newItem)
            }
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
