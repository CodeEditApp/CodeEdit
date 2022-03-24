//
//  InspectorSidebar.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/21/22.
//

import SwiftUI
import WorkspaceClient

struct InspectorSidebar: View {
    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController
    @State private var selection: Int = 0

    var body: some View {
        VStack {
            switch selection {
            case 0:
                FileInspectorView()
            case 1:
                HistoryInspector()
            case 2:
                QuickHelpInspector().padding(5)
            default: EmptyView()
            }
        }
        .frame(
            minWidth: 250,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
        .safeAreaInset(edge: .top) {
            InspectorSidebarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
    }
}
