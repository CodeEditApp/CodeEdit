//
//  SideBarToolbar.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 17.03.22.
//

import SwiftUI

struct SideBarToolbarTop: View {
	@Binding var selection: Int

	var body: some View {
		HStack(spacing: 10) {
			icon(systemImage: "folder", title: "Project", id: 0)
			icon(systemImage: "globe", title: "Version Control", id: 1)
			icon(systemImage: "magnifyingglass", title: "Search", id: 2)
			icon(systemImage: "shippingbox", title: "...", id: 3)
			icon(systemImage: "play", title: "...", id: 4)
			icon(systemImage: "exclamationmark.triangle", title: "...", id: 5)
			icon(systemImage: "curlybraces.square", title: "...", id: 6)
			icon(systemImage: "puzzlepiece.extension", title: "...", id: 7)
			icon(systemImage: "square.grid.2x2", title: "...", id: 8)
		}
		.frame(height: 29, alignment: .center)
		.frame(maxWidth: .infinity)
		.overlay(alignment: .top) {
			Divider()
		}
		.overlay(alignment: .bottom) {
			Divider()
		}
	}

	func icon(systemImage: String, title: String, id: Int) -> some View {
		Button { selection = id } label: {
			Image(systemName: systemImage)
				.help(title)
				.symbolVariant(id == selection ? .fill : .none)
				.foregroundColor(id == selection ? .blue : .secondary)
		}
		.buttonStyle(.plain)
	}
}

struct SideBarToolbar_Previews: PreviewProvider {
	static var previews: some View {
		SideBarToolbarTop(selection: .constant(0))
	}
}
