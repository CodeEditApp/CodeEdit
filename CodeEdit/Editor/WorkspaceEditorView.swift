//
//  WorkspaceEditorView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 12.03.22.
//

import SwiftUI
import WorkspaceClient

struct WorkspaceEditorView: View {
    @ObservedObject var workspace: WorkspaceDocument
    var item: WorkspaceClient.FileItem
    var windowController: NSWindowController
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if let file = workspace.openedCodeFiles[item] {
                CodeFileEditor(file: file)
            } else {
                Text("File cannot be opened")
            }
        }
            .background(Color(nsColor: NSColor.textBackgroundColor))
            .onAppear { workspace.openFile(item: item) }
    }
}
