//
//  BreadcrumbsMenu.swift
//  CodeEdit
//
//  Created by Ziyuan Zhao on 2022/3/24.
//

import SwiftUI
import WorkspaceClient

struct BreadcrumbsMenu: View {
	@ObservedObject var workspace: WorkspaceDocument
	private var parentFileItem: WorkspaceClient.FileItem?
	private let title: String
	private let image: String
	private let color: Color

	init(
		_ workspace: WorkspaceDocument,
		title: String,
		systemImage image: String,
		color: Color = .secondary,
		parentFileItem: WorkspaceClient.FileItem? = nil
	) {
		self.workspace = workspace
		self.title = title
		self.image = image
		self.color = color
		self.parentFileItem = parentFileItem
	}

	private func menuItem(_ item: WorkspaceClient.FileItem) -> some View {
		if let children = item.children, !children.isEmpty {
			// Folder
			return AnyView(
				Menu {
					ForEach(children) { item in
						menuItem(item)
					}
				} label: {
					BreadcrumbsComponent(item.fileName, systemImage: "folder.fill")
				}
				.menuIndicator(.hidden)
				.menuStyle(.borderlessButton)
			)
		} else {
			// File
			return AnyView(Button {
				workspace.openFile(item: item)
			} label: {
				BreadcrumbsComponent(item.fileName, systemImage: item.fileIcon, color: item.iconColor)
			})
		}
	}

	var body: some View {
		Menu {
			if let siblings = parentFileItem?.children {
				ForEach(siblings, id: \.self) { item in
					menuItem(item)
				}
			}
		} label: {
			BreadcrumbsComponent(self.title, systemImage: self.image, color: self.color)
		}
		.menuIndicator(.hidden)
		.menuStyle(.borderlessButton)
	}
}
