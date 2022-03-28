//
//  StatusBarIndentSelector.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

@available(macOS 12, *)
internal struct StatusBarIndentSelector: View {
	@ObservedObject
    private var model: StatusBarModel

	internal init(model: StatusBarModel) {
		self.model = model
	}

	internal var body: some View {
		Menu {
			// 2 spaces, 4 spaces, ...
		} label: {
			Text("2 Spaces")
				.font(model.toolbarFont)
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
		.onHover { isHovering($0) }
	}
}
