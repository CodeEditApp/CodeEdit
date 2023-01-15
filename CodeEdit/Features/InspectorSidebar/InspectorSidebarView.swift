//
//  InspectorSidebarView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI

struct InspectorSidebarView: View {

    @ObservedObject
    private var workspace: WorkspaceDocument

    @State
    private var selection: Int = 0

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            if let item = workspace.selectionState.openFileItems.first(where: { file in
                file.tabID == workspace.selectionState.selectedId
            }) {
                if let codeFile = workspace.selectionState.openedCodeFiles[item] {
                    switch selection {
                    case 0:
                        FileInspectorView(
                            workspaceURL: workspace.fileURL!,
                            fileURL: codeFile.fileURL!.path
                        )
                    case 1:
                        HistoryInspectorView(
                            workspaceURL: workspace.fileURL!,
                            fileURL: codeFile.fileURL!.path
                        )
                    case 2:
                        QuickHelpInspectorView().padding(5)
                    default: EmptyView()
                    }
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .frame(
            minWidth: CodeEditWindowController.minSidebarWidth,
            idealWidth: 260,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
        .safeAreaInset(edge: .top) {
            InspectorSidebarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
        .background(
            EffectView(.windowBackground, blendingMode: .withinWindow)
        )
    }
}
