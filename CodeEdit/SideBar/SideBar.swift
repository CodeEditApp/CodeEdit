//
//  SideBar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct SideBar: View {

	var directoryURL: URL
	var workspaceClient: WorkspaceClient
	@Binding var openFileItems: [WorkspaceClient.FileItem]
	@Binding var selectedId: UUID?

    var body: some View {
		List {
			Section(header: Text(directoryURL.lastPathComponent)) {
				ForEach(workspaceClient.getFiles()) { item in // Instead of OutlineGroup
					SideBarItem(item: item,
								directoryURL: directoryURL,
								workspaceClient: workspaceClient,
								openFileItems: $openFileItems,
								selectedId: $selectedId)
				}
			}
		}
    }
}
