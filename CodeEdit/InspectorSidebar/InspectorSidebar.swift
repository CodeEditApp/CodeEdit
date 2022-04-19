//
//  InspectorSidebar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI
import WorkspaceClient

struct InspectorSidebar: View {
    @ObservedObject
    var workspace: WorkspaceDocument

    var windowController: NSWindowController

    @State
    private var selection: Int = 0

    var body: some View {
        VStack {
            if let item = workspace.selectionState.openFileItems.first(where: { file in
                return file.id == workspace.selectionState.selectedId
            }) {
                if let codeFile = workspace.selectionState.openedCodeFiles[item] {
                    switch selection {
                    case 0:
                        FileInspectorView(workspaceURL: workspace.fileURL!,
                                          fileURL: codeFile.fileURL!.path)
                    case 1:
                        HistoryInspector(workspaceURL: workspace.fileURL!,
                                         fileURL: codeFile.fileURL!.path)
                    case 2:
                        QuickHelpInspector().padding(5)
                    default: EmptyView()
                    }
                }
            } else {
                NoSelectionView()
            }
        }
        .frame(
            minWidth: 250,
            idealWidth: 260,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
        .safeAreaInset(edge: .top) {
            InspectorSidebarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
        .background(Rectangle()
            .foregroundColor(Color("InspectorBackgroundColor")))
    }
}
