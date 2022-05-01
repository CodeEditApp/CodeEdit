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
import Breadcrumbs

struct WorkspaceCodeFileView: View {
    var windowController: NSWindowController
    @ObservedObject var workspace: WorkspaceDocument

    @ViewBuilder
    var codeView: some View {
        ZStack {
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
                                BreadcrumbsView(file: item, tappedOpenFile: workspace.openFile(item:))
                                Divider()
                            }
                        }
                } else {
                    Text("CodeEdit cannot open this file because its file type is not supported.")
                        .frame(minHeight: 0)
                        .clipped()
                }
            } else {
                Text("No Editor")
                    .font(.system(size: 17))
                    .foregroundColor(.secondary)
                    .frame(minHeight: 0)
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                TabBar(windowController: windowController, workspace: workspace)
                TabBarBottomDivider()
            }
        }
    }

    var body: some View {
        codeView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
