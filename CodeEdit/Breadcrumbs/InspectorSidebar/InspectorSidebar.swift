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
                    Text("File Inspector")
                case 1:
                    Text("History Inspector")
                case 2:
                    Text("Quick Help Inspector")
                default: EmptyView()
            }
        }
        .frame(
            minWidth: 250,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
        )
        .safeAreaInset(edge: .top) {
            InspectorSidebarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
    }
}
