//
//  WorkspaceCodeFileEditor.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import CodeFile
import WorkspaceClient

struct WorkspaceCodeFileView: View {
    var codeFile: CodeFileDocument
    var windowController: NSWindowController
    var workspace: WorkspaceDocument
    var item: WorkspaceClient.FileItem

    var body: some View {
        CodeFileView(codeFile: codeFile)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    TabBar(windowController: windowController, workspace: workspace)
                    CustomDivider()
                    BreadcrumbsView(item, workspace: workspace)
                }
            }
    }
}
