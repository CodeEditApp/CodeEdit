//
//  WorkspaceCodeFileEditor.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import SwiftUI
import CodeFile
import WorkspaceClient
import StatusBar

struct WorkspaceCodeFileView: View {
    var windowController: NSWindowController
    @ObservedObject var workspace: WorkspaceDocument

    @ViewBuilder var body: some View {
        if let item = workspace.openFileItems.first(where: { file in
            return file.id == workspace.selectedId
        }) {
            if let codeFile = workspace.openedCodeFiles[item] {
                CodeFileView(codeFile: codeFile)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            TabBar(windowController: windowController, workspace: workspace)
                            TabBarDivider()
                            BreadcrumbsView(item, workspace: workspace)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        StatusBarView()
                    }
            } else {
                Text("CodeEdit cannot open this file because its file type is not supported.")
            }
        } else {
            Text("Open file from sidebar")
        }
    }
}
