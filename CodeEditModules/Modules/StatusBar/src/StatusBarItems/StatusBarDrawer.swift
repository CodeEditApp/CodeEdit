//
//  StatusBarDrawer.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import TerminalEmulator

internal struct StatusBarDrawer: View {
	@ObservedObject
    private var model: StatusBarModel

	internal init(model: StatusBarModel) {
		self.model = model
	}

	internal var body: some View {
		TerminalEmulatorView(url: model.workspaceURL)
			.frame(minHeight: 0,
				   idealHeight: model.isExpanded ? model.currentHeight : 0,
				   maxHeight: model.isExpanded ? model.currentHeight : 0)
	}
}
