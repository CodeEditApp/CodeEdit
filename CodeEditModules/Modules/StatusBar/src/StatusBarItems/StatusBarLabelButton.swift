//
//  StatusBarLabelButton.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

@available(macOS 12, *)
internal struct StatusBarLabelButton: View {

	@ObservedObject private var model: StatusBarModel

	private var title: String
	private var image: String

	internal init(model: StatusBarModel, title: String, image: String) {
		self.model = model
		self.title = title
		self.image = image
	}

	internal var body: some View {
		Button {
			// show errors/warnings
		} label: {
			HStack(spacing: 2) {
				Image(systemName: image)
					.font(.callout.bold())
				Text(title)
					.font(model.toolbarFont)
			}
		}
		.buttonStyle(.borderless)
		.foregroundStyle(.primary)
		.onHover { isHovering($0) }
	}

}
