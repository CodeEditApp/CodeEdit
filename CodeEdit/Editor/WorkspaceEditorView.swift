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
        if let file = workspace.openedCodeFiles[item] {
            ScrollView(.vertical, showsIndicators: true) {
                CodeFileEditor(file: file)
            }
                .background(Color(nsColor: NSColor.textBackgroundColor))
        }
    }
}
