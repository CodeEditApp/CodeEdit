//
//  StatusBar.swift
//  
//
//  Created by Lukas Pistrol on 19.03.22.
//

import SwiftUI
import GitClient

@available(macOS 12, *)
public struct StatusBarView: View {

	@ObservedObject private var model: StatusBarModel

	private var toolbarFont: Font = .system(size: 11)
    private let gitClient: GitClient
	private let maxHeight: Double = 500
	private let standardHeight: Double = 300
	private let minHeight: Double = 100

	@State private var currentHeight: Double = 0
	@State private var isDragging: Bool = false

    public init(gitClient: GitClient) {
		self.model = .init()
        self.gitClient = gitClient
        model.selectedBranch = gitClient.getCurrentBranchName()
	}

	public var body: some View {
		VStack(spacing: 0) {
			bar
			terminal
		}
		// removes weird light gray bar above when in light mode
		.padding(.top, -8) // (comment out to make it look normal in preview)
	}

	private var dragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				isDragging = true
				var newHeight = max(0, min(currentHeight - value.translation.height, 500))
				if newHeight-0.5 > currentHeight || newHeight+0.5 < currentHeight {
					if newHeight < minHeight { // simulate the snapping/resistance after reaching minimal height
						if newHeight > minHeight / 2 {
							newHeight = minHeight
						} else {
							newHeight = 0
						}
					}
					currentHeight = newHeight
				}
				model.isExpanded = currentHeight < 1 ? false : true
			}
			.onEnded { _ in
				isDragging = false
			}
	}

	private var bar: some View {
		ZStack {
			Rectangle()
				.foregroundStyle(.bar)
			HStack(spacing: 15) {
				HStack(spacing: 5) {
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
		.onHover { isHovering($0, cursor: .resizeUpDown) }
	}

	private var terminal: some View {
		Rectangle()
			.foregroundColor(Color(red: 0.163, green: 0.163, blue: 0.188, opacity: 1.000))
			.frame(minHeight: 0,
				   idealHeight: model.isExpanded ? currentHeight : 0,
				   maxHeight: model.isExpanded ? currentHeight : 0)
	}

	private func labelButton(_ text: String, image: String) -> some View {
		Button {
			// show errors/warnings
		} label: {
			HStack(spacing: 2) {
				Image(systemName: image)
					.font(.callout.bold())
				Text(text)
					.font(toolbarFont)
			}
		}
		.buttonStyle(.borderless)
		.foregroundStyle(.primary)
		.onHover { isHovering($0) }
	}

	private var branchPicker: some View {
        Menu {
            ForEach(gitClient.getBranches(), id: \.self) { branch in
                Button {
                    do {
                        guard model.selectedBranch != branch else { return }
                        try gitClient.checkoutBranch(branch)
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
            Text(model.selectedBranch)
				.font(toolbarFont)
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
		.onHover { isHovering($0) }
	}

	private var reloadButton: some View {
		Button {
			model.isReloading = true
            gitClient.pull()
			// Just for looks for now. In future we'll call a function like
			// `reloadFileStatus()` here which will set/unset `reloading`
			DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
				self.model.isReloading = false
			}
		} label: {
			Image(systemName: "arrow.triangle.2.circlepath")
				.imageScale(.medium)
				.rotationEffect(.degrees(model.isReloading ? 360 : 0))
				.animation(animation, value: model.isReloading)
				.opacity(model.isReloading ? 1 : 0)
			// A bit of a hacky solution to prevent spinning counterclockwise once `reloading` changes to `false`
				.overlay {
					Image(systemName: "arrow.triangle.2.circlepath")
						.imageScale(.medium)
						.opacity(model.isReloading ? 0 : 1)
				}

		}
		.buttonStyle(.borderless)
		.foregroundStyle(.primary)
		.onHover { isHovering($0) }
	}

	// Temporary
	private var animation: Animation {
		// 10x speed when not reloading to make invisible ccw spin go fast in case button is pressed multiple times.
		.linear.speed(model.isReloading ? 0.5 : 10)
	}

	private var cursorLocationLabel: some View {
		Text("Ln \(model.currentLine), Col \(model.currentCol)")
			.font(toolbarFont)
			.foregroundStyle(.primary)
			.lineLimit(1)
			.onHover { isHovering($0) }
	}

	private var indentSelector: some View {
		Menu {
			// 2 spaces, 4 spaces, ...
		} label: {
			Text("2 Spaces")
				.font(toolbarFont)
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
		.onHover { isHovering($0) }
	}

	private var encodingSelector: some View {
		Menu {
			// UTF 8, ASCII, ...
		} label: {
			Text("UTF 8")
				.font(toolbarFont)
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
		.onHover { isHovering($0) }
	}

	private var lineEndSelector: some View {
		Menu {
			// LF, CRLF
		} label: {
			Text("LF")
				.font(toolbarFont)
		}
		.menuStyle(.borderlessButton)
		.fixedSize()
		.onHover { isHovering($0) }
	}

	private var expandButton: some View {
		Button {
			withAnimation {
				model.isExpanded.toggle()
				if model.isExpanded && currentHeight < 1 {
					currentHeight = 300
				}
			}
			// Show/hide terminal window
		} label: {
			Image(systemName: "rectangle.bottomthird.inset.filled")
				.imageScale(.medium)
		}
		.tint(model.isExpanded ? .accentColor : .primary)
		.keyboardShortcut("Y", modifiers: [.command, .shift])
		.buttonStyle(.borderless)
		.onHover { isHovering($0) }
	}

	private func isHovering(_ active: Bool, cursor: NSCursor = .arrow) {
		if isDragging { return }
		print("Change Cursor")
		if active {
			cursor.push()
		} else {
			NSCursor.pop()
		}
	}
}

@available(macOS 12, *)
struct SwiftUIView_Previews: PreviewProvider {
	static var previews: some View {
		ZStack(alignment: .bottom) {
			Color.white
            StatusBarView(gitClient: .default(directoryURL: URL(fileURLWithPath: "")))
				.previewLayout(.fixed(width: 1.336, height: 500.0))
				.preferredColorScheme(.light)
		}
	}
}
