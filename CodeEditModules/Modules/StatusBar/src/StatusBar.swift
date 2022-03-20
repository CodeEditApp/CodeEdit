//
//  StatusBar.swift
//  
//
//  Created by Lukas Pistrol on 19.03.22.
//

import SwiftUI

public struct StatusBarView: View {

	public init(errors: Int, warnings: Int) {
		self.errors = errors
		self.warnings = warnings
	}

	private var errors: Int
	private var warnings: Int
	private var branches: [String] = ["master", "new-feature"]

	// TODO: Create a View Model for this
	@State private var selectedBranch: Int = 0
	@State private var isExpanded: Bool = false
	@State private var reloading: Bool = false
	@State private var line: Int = 1
	@State private var col: Int = 1

    public var body: some View {
		ZStack {
			Rectangle()
				.foregroundStyle(.bar)
			HStack(spacing: 14) {
				HStack(spacing: 8) {
				labelButton(errors.formatted(), image: "xmark.octagon")
				labelButton(warnings.formatted(), image: "exclamationmark.triangle")
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
		.padding(.top, -8)
    }

	private func labelButton(_ text: String, image: String) -> some View {
		Button {} label: {
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
		Menu(branches[selectedBranch]) {
			ForEach(branches.indices, id: \.self) { branch in
				Button { selectedBranch = branch } label: {
					Text(branches[branch])
				}
			}
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
	}

	private var reloadButton: some View {
		Button {
			reloading = true
			// Just for looks for now. In future we'll call a function like
			// `reloadFileStatus()` here which will set/unset `reloading`
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.reloading = false
			}
		} label: {
			Image(systemName: "arrow.triangle.2.circlepath")
				.imageScale(.large)
				.rotationEffect(.degrees(reloading ? 360 : 0))
				.animation(animation, value: reloading)
				.opacity(reloading ? 1 : 0)
			// A bit of a hacky solution to prevent spinning counterclockwise once `reloading` changes to `false`
				.overlay {
					Image(systemName: "arrow.triangle.2.circlepath")
						.imageScale(.large)
						.opacity(reloading ? 0 : 1)
				}

		}
		.buttonStyle(.borderless)
		.foregroundStyle(.primary)
	}

	private var animation: Animation {
		// 10x speed when not reloading to make invisible ccw spin go fast in case button is pressed multiple times.
		.linear.speed(reloading ? 0.5 : 10)
	}

	private var cursorLocationLabel: some View {
		Text("Ln \(line), Col \(col)")
			.foregroundStyle(.primary)
	}

	private var indentSelector: some View {
		Menu("2 Spaces") {}
		.menuStyle(.borderlessButton)
		.fixedSize()
	}

	private var encodingSelector: some View {
		Menu("UTF 8") {}
			.menuStyle(.borderlessButton)
			.fixedSize()
	}

	private var lineEndSelector: some View {
		Menu("LF") {}
			.menuStyle(.borderlessButton)
			.fixedSize()
	}

	private var expandButton: some View {
		Button {
			isExpanded.toggle()
		} label: {
			Image(systemName: "rectangle.bottomthird.inset.filled")
				.imageScale(.large)
		}
		.tint(isExpanded ? .accentColor : .secondary)
		.buttonStyle(.borderless)
	}
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
		StatusBarView(errors: 0, warnings: 0)
			.previewLayout(.fixed(width: 1336, height: 32))
			.preferredColorScheme(.light)
    }
}
