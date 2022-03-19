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

	@State private var selectedBranch: Int = 0
	@State private var isExpanded: Bool = false

    public var body: some View {
		ZStack {
			Rectangle()
				.foregroundStyle(.bar)
			HStack {
				labelButton(errors.formatted(), image: "xmark.octagon")
				labelButton(warnings.formatted(), image: "exclamationmark.triangle")
				branchPicker
				Spacer()
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
	}

	private var branchPicker: some View {
		Menu(branches[selectedBranch]) {
			ForEach(branches.indices, id: \.self) { branch in
				Button { selectedBranch = branch } label: {
					Text(branches[branch])
						.foregroundColor(.black)
				}
			}
		}
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
			.preferredColorScheme(.dark)
    }
}
