//
//  StatusBarBranchPicker.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import GitClient

internal struct StatusBarBranchPicker: View {

	@ObservedObject private var model: StatusBarModel

	internal init(model: StatusBarModel) {
		self.model = model
	}

	internal var body: some View {
		Menu {

			ForEach(model.gitClient.getBranches(), id: \.self) { branch in
				Button {
					do {
						guard model.selectedBranch != branch else { return }
						try model.gitClient.checkoutBranch(branch)
						model.selectedBranch = branch
					} catch {
						guard let error = error as? GitClient.GitClientError else { return }
						switch error {
						case let .outputError(message):
							let alert = NSAlert()
							alert.messageText = message
							alert.alertStyle = .critical
							alert.addButton(withTitle: "Ok")
							alert.runModal()
						}
					}
				} label: {
					Text(branch)
					// checkout branch
				}
			}
		} label: {
			Text(model.selectedBranch ?? "No Git Repository")
				.font(model.toolbarFont)
		}
		.menuStyle(.borderlessButton)
        .fixedSize(horizontal: false, vertical: true)
		.onHover { isHovering($0) }
		.disabled(model.selectedBranch == nil)
	}
}
