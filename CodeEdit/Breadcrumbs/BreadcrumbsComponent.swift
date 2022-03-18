//
//  BreadcrumbsComponent.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 18.03.22.
//

import SwiftUI

struct BreadcrumbsComponent: View {

	@AppStorage(FileIconStyle.storageKey) var iconStyle: FileIconStyle = .default
	
	private let title: String
	private let image: String
	private let color: Color
	
	init(_ title: String, systemImage image: String, color: Color = .secondary) {
		self.title = title
		self.image = image
		self.color = color
	}
	
	var body: some View {
		HStack {
			Image(systemName: image)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 12)
				.foregroundStyle(iconStyle == .color ? color : .secondary)
			Text(title)
				.foregroundStyle(.primary)
				.font(.system(size: 11))
		}
	}
}

