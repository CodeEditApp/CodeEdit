//
//  StatusBar.swift
//  
//
//  Created by Lukas Pistrol on 19.03.22.
//

import SwiftUI

@available(macOS 12, *)
public struct StatusBarView: View {

	@ObservedObject private var model: StatusBarModel

	public init() {
		self.model = .init()
	}

    public var body: some View {
		VStack(spacing: 0) {
			bar
			if model.isExpanded {
				terminal
			}
		}
		// removes weird light gray bar above when in light mode 
		.padding(.top, -8) // (comment out to make it look normal in preview)
    }

	private var dragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				let newHeight = max(0, min(height - value.translation.height, 500))
				if newHeight-1 > height || newHeight+1 < height {
					height = newHeight
				}
				model.isExpanded = height < 1 ? false : true
			}
	}

	private var bar: some View {
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
		.gesture(dragGesture)
		.onHover { hovering in
			if hovering {
				NSCursor.resizeUpDown.push()
			} else {
				NSCursor.pop()
			}
		}
	}

	@State private var height: Double = 300

	private var terminal: some View {
		Rectangle()
			.foregroundColor(Color(red: 0.163, green: 0.163, blue: 0.188, opacity: 1.000))
			.frame(minHeight: 0, idealHeight: height, maxHeight: height)
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
		.onHover { hovering in
			if hovering {
				NSCursor.pointingHand.push()
			} else {
				NSCursor.pop()
			}
		}
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
		.onHover { hovering in
			if hovering {
				NSCursor.pointingHand.push()
			} else {
				NSCursor.pop()
			}
		}
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
		.onHover { hovering in
			if hovering {
				NSCursor.pointingHand.push()
			} else {
				NSCursor.pop()
			}
		}
	}

	// Temporary
	private var animation: Animation {
		// 10x speed when not reloading to make invisible ccw spin go fast in case button is pressed multiple times.
		.linear.speed(model.isReloading ? 0.5 : 10)
	}

	private var cursorLocationLabel: some View {
		Text("Ln \(model.currentLine), Col \(model.currentCol)")
			.foregroundStyle(.primary)
			.onHover { hovering in
				if hovering {
					NSCursor.pointingHand.push()
				} else {
					NSCursor.pop()
				}
			}
	}

	private var indentSelector: some View {
		Menu("2 Spaces") {
			// 2 spaces, 4 spaces, ...
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
		.onHover { hovering in
			if hovering {
				NSCursor.pointingHand.push()
			} else {
				NSCursor.pop()
			}
		}
	}

	private var encodingSelector: some View {
		Menu("UTF 8") {
			// UTF 8, ASCII, ...
		}
			.menuStyle(.borderlessButton)
			.fixedSize()
			.onHover { hovering in
				if hovering {
					NSCursor.pointingHand.push()
				} else {
					NSCursor.pop()
				}
			}
	}

	private var lineEndSelector: some View {
		Menu("LF") {
			// LF, CRLF
		}
			.menuStyle(.borderlessButton)
			.fixedSize()
			.onHover { hovering in
				if hovering {
					NSCursor.pointingHand.push()
				} else {
					NSCursor.pop()
				}
			}
	}

	private var expandButton: some View {
		Button {
			model.isExpanded.toggle()
			if model.isExpanded && height < 1 {
				height = 300
			}
			// Show/hide terminal window
		} label: {
			Image(systemName: "rectangle.bottomthird.inset.filled")
				.imageScale(.large)
		}
		.tint(model.isExpanded ? .accentColor : .primary)
		.buttonStyle(.borderless)
		.onHover { hovering in
			if hovering {
				NSCursor.pointingHand.push()
			} else {
				NSCursor.pop()
			}
		}
	}
}

@available(macOS 12, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
		ZStack(alignment: .bottom) {
			Color.white
			StatusBarView()
				.previewLayout(.fixed(width: 1.336, height: 500.0))
				.preferredColorScheme(.light)
		}
    }
}
