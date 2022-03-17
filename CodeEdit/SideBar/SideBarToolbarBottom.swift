//
//  SideBarToolbarBottom.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct SideBarToolbarBottom: View {

	@ObservedObject var workspace: WorkspaceDocument

    var body: some View {
		HStack(spacing: 10) {
			addNewFileButton
			Spacer()
			sortButton
		}
		.frame(height: 32, alignment: .center)
		.frame(maxWidth: .infinity)
		.padding(.horizontal, 4)
		.overlay(alignment: .top) {
			Divider()
		}
    }

	private var addNewFileButton: some View {
		Menu {
			Button("Add File") {}
				.disabled(true)
			Button("Not implemented yet") {}
				.disabled(true)
		} label: {
			Image(systemName: "plus")
		}
		.menuStyle(.borderlessButton)
		.menuIndicator(.hidden)
		.frame(maxWidth: 30)
	}

	private var sortButton: some View {
		Menu {
			Button {
				workspace.sortFoldersOnTop.toggle()
			} label: {
				Text(workspace.sortFoldersOnTop ? "Alphabetically" : "Folders on top")
			}
		} label: {
			Image(systemName: "line.3.horizontal.decrease.circle")
		}
		.menuStyle(.borderlessButton)
		.frame(maxWidth: 30)
	}
}
