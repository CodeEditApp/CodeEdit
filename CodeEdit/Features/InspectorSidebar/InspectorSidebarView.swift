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

    @EnvironmentObject
    private var tabManager: TabManager

    @State
    private var selection: Int = 0

    init(workspace: WorkspaceDocument) {
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            if let path = tabManager.activeTabGroup.selected?.fileDocument?.fileURL {
                switch selection {
                case 0:
                    FileInspectorView(
                        workspaceURL: workspace.fileURL!,
                        fileURL: path.path(percentEncoded: false),
                        fileType: path.pathExtension
                    )
                case 1:
                    HistoryInspectorView(
                        workspaceURL: workspace.fileURL!,
                        fileURL: path.path(percentEncoded: false)
                    )
                case 2:
                    QuickHelpInspectorView().padding(5)
                default:
                    NoSelectionInspectorView()
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
        .safeAreaInset(edge: .top, spacing: 0) {
            InspectorSidebarToolbarTop(selection: $selection)
                .background(.ultraThinMaterial)
        }
    }
}
