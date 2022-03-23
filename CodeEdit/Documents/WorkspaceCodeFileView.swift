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

    @ViewBuilder var codeView: some View {
        if let item = workspace.selectionState.openFileItems.first(where: { file in
            if file.id == workspace.selectionState.selectedId {
                print("Item loaded is: ", file.url)
            }
            return file.id == workspace.selectionState.selectedId
        }) {
            if let codeFile = workspace.selectionState.openedCodeFiles[item] {
                CodeFileView(codeFile: codeFile)
                    .safeAreaInset(edge: .top, spacing: 0) {
                        VStack(spacing: 0) {
                            TabBar(windowController: windowController, workspace: workspace)
                            TabBarDivider()
                            BreadcrumbsView(item, workspace: workspace)
                        }
                    }
                    .safeAreaInset(edge: .bottom) {
                        if let url = workspace.fileURL {
							StatusBarView(workspaceURL: url)
                        }
                    }
            } else {
                Text("CodeEdit cannot open this file because its file type is not supported.")
            }
        } else {
            Text("Open file from sidebar")
        }
    }

    var body: some View {
        HSplitView {
            codeView
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            InspectorSidebar(workspace: workspace, windowController: windowController)
                .frame(minWidth: 250, maxWidth: 250, maxHeight: .infinity)
        }
    }
}
