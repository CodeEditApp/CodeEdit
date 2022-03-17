//
//  TabBarItem.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI
import WorkspaceClient

struct TabBarItem: View {
	var item: WorkspaceClient.FileItem

	@Binding var selectedId: UUID?
	@Binding var openFileItems: [WorkspaceClient.FileItem]

	var tabBarHeight: Double

    var body: some View {
		let isActive = selectedId == item.id
		HStack(spacing: 0.0) {
			Button {
				selectedId = item.id
			} label: {
				FileTabRow(fileItem: item, isSelected: isActive, closeAction: {
					withAnimation {
						closeFileTab(item: item)
					}
				})
				.frame(height: tabBarHeight)
				.foregroundColor(.primary.opacity(isActive ? 0.9 : 0.55))
			}
			.buttonStyle(.plain)
			.background {
				(isActive ? Color(red: 0.219, green: 0.219, blue: 0.219) : Color(red: 0.113, green: 0.113, blue: 0.113))
					.opacity(0.85)
			}

			Divider()
				.foregroundColor(.primary.opacity(0.25))
		}
		.animation(.easeOut(duration: 0.2), value: openFileItems)
    }

	func closeFileTab(item: WorkspaceClient.FileItem) {
		guard let idx = openFileItems.firstIndex(of: item) else { return }
		let closedFileItem = openFileItems.remove(at: idx)
		guard closedFileItem.id == selectedId else { return }

		if openFileItems.isEmpty {
			selectedId = nil
		} else if idx == 0 {
			selectedId = openFileItems.first?.id
		} else {
			selectedId = openFileItems[idx - 1].id
		}
	}
}
