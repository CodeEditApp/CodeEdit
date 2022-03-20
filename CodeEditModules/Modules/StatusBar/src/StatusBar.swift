//
//  StatusBar.swift
//  
//
//  Created by Lukas Pistrol on 19.03.22.
//

import SwiftUI

public struct StatusBarView: View {

	@ObservedObject private var model: StatusBarModel

	public init() {
		self.model = .init()
	}

    public var body: some View {
		ZStack {
			Rectangle()
				.foregroundStyle(.bar)
			HStack(spacing: 14) {
				HStack(spacing: 8) {
					labelButton(model.errorCount.formatted(), image: "xmark.octagon")
					labelButton(model.warningCount.formatted(), image: "exclamationmark.triangle")
				}
				branchPicker
				reloadButton
				Spacer()
				cursorLocationLabel
				indentSelector
				encodingSelector
				lineEndSelector
				expandButton
			}
			.padding(.horizontal, 10)
		}
		.overlay(alignment: .top) {
			Divider()
		}
		.frame(height: 32)
		.padding(.top, -8) // removes weird light gray bar above when in light mode (comment out to make it look normal in preview)
    }

	private func labelButton(_ text: String, image: String) -> some View {
		Button {
			// show errors/warnings
		} label: {
			HStack(spacing: 4) {
				Image(systemName: image)
					.font(.headline)
				Text(text)
			}
		}
		.buttonStyle(.borderless)
		.foregroundStyle(.primary)
	}

	private var branchPicker: some View {
		Menu(model.branches[model.selectedBranch]) {
			ForEach(model.branches.indices, id: \.self) { branch in
				Button { model.selectedBranch = branch } label: {
					Text(model.branches[branch])
					// checkout branch
				}
			}
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
	}

	private var reloadButton: some View {
		// Temporary
		Button {
			model.isReloading = true
			// Just for looks for now. In future we'll call a function like
			// `reloadFileStatus()` here which will set/unset `reloading`
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.model.isReloading = false
			}
		} label: {
			Image(systemName: "arrow.triangle.2.circlepath")
				.imageScale(.large)
				.rotationEffect(.degrees(model.isReloading ? 360 : 0))
				.animation(animation, value: model.isReloading)
				.opacity(model.isReloading ? 1 : 0)
			// A bit of a hacky solution to prevent spinning counterclockwise once `reloading` changes to `false`
				.overlay {
					Image(systemName: "arrow.triangle.2.circlepath")
						.imageScale(.large)
						.opacity(model.isReloading ? 0 : 1)
				}

		}
		.buttonStyle(.borderless)
		.foregroundStyle(.primary)
	}

	// Temporary
	private var animation: Animation {
		// 10x speed when not reloading to make invisible ccw spin go fast in case button is pressed multiple times.
		.linear.speed(model.isReloading ? 0.5 : 10)
	}

	private var cursorLocationLabel: some View {
		Text("Ln \(model.currentLine), Col \(model.currentCol)")
			.foregroundStyle(.primary)
	}

	private var indentSelector: some View {
		Menu("2 Spaces") {
			// 2 spaces, 4 spaces, ...
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
	}

	private var encodingSelector: some View {
		Menu("UTF 8") {
			// UTF 8, ASCII, ...
		}
			.menuStyle(.borderlessButton)
			.fixedSize()
	}

	private var lineEndSelector: some View {
		Menu("LF") {
			// LF, CRLF
		}
			.menuStyle(.borderlessButton)
			.fixedSize()
	}

	private var expandButton: some View {
		Button {
			model.isExpanded.toggle()
			// Show/hide terminal window
		} label: {
			Image(systemName: "rectangle.bottomthird.inset.filled")
				.imageScale(.large)
		}
		.tint(model.isExpanded ? .accentColor : .primary)
		.buttonStyle(.borderless)
	}
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
		StatusBarView()
			.previewLayout(.fixed(width: 1336, height: 32))
			.preferredColorScheme(.light)
    }
}
