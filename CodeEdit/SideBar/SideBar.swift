//
//  SideBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct SideBar: View {

    @ObservedObject var workspace: WorkspaceDocument
    var windowController: NSWindowController

	@State private var selection: Int = 0

	var body: some View {
		List {
            Section(header: Text(workspace.fileURL?.lastPathComponent ?? "Unknown")) {
                ForEach(workspace.workspaceClient?.getFiles() ?? []) { item in // Instead of OutlineGroup
					SideBarItem(item: item,
								workspace: workspace,
                                windowController: windowController)
				}
			}
		}
		.safeAreaInset(edge: .top) {
			SideBarToolbar(selection: $selection)
				.padding(.bottom, -8)
		}
	}
}
