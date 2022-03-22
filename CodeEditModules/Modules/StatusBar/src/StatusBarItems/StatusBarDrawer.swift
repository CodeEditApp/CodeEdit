//
//  StatusBarDrawer.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

internal struct StatusBarDrawer: View {

	@ObservedObject private var model: StatusBarModel

	internal init(model: StatusBarModel) {
		self.model = model
	}

	internal var body: some View {
		Rectangle()
			.foregroundColor(Color(red: 0.163, green: 0.163, blue: 0.188, opacity: 1.000))
			.frame(minHeight: 0,
				   idealHeight: model.isExpanded ? model.currentHeight : 0,
				   maxHeight: model.isExpanded ? model.currentHeight : 0)
	}
}
