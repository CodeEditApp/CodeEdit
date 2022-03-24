import Cocoa
import SwiftUI

// swiftlint:disable all

extension NSImage {
	static var empty: NSImage { NSImage(size: .zero) }
}

extension NSView {
	@discardableResult
	func constrainToSuperviewBounds() -> [NSLayoutConstraint] {
		guard let superview = superview else {
			preconditionFailure("superview has to be set first")
		}

		var result = [NSLayoutConstraint]()
		result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
		result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
		translatesAutoresizingMaskIntoConstraints = false
		superview.addConstraints(result)

		return result
	}
}

extension NSEvent {
	/// Events triggered by user interaction.
	static let userInteractionEvents: [NSEvent.EventType] = {
		var events: [NSEvent.EventType] = [
			.leftMouseDown,
			.leftMouseUp,
			.rightMouseDown,
			.rightMouseUp,
			.leftMouseDragged,
			.rightMouseDragged,
			.keyDown,
			.keyUp,
			.scrollWheel,
			.tabletPoint,
			.otherMouseDown,
			.otherMouseUp,
			.otherMouseDragged,
			.gesture,
			.magnify,
			.swipe,
			.rotate,
			.beginGesture,
			.endGesture,
			.smartMagnify,
			.quickLook,
			.directTouch
		]

		if #available(macOS 10.10.3, *) {
			events.append(.pressure)
		}

		return events
	}()

	/// Whether the event was triggered by user interaction.
	var isUserInteraction: Bool { NSEvent.userInteractionEvents.contains(type) }
}

extension Bundle {
	var appName: String {
		string(forInfoDictionaryKey: "CFBundleDisplayName")
			?? string(forInfoDictionaryKey: "CFBundleName")
			?? string(forInfoDictionaryKey: "CFBundleExecutable")
			?? "<Unknown App Name>"
	}

	private func string(forInfoDictionaryKey key: String) -> String? {
		// `object(forInfoDictionaryKey:)` prefers localized info dictionary over the regular one automatically
		object(forInfoDictionaryKey: key) as? String
	}
}


/**
A window that allows you to disable all user interactions via `isUserInteractionEnabled`.

Used to avoid breaking animations when the user clicks too fast. Disable user interactions during animations and you're set.
*/
class UserInteractionPausableWindow: NSWindow {
	var isUserInteractionEnabled = true

	override func sendEvent(_ event: NSEvent) {
		guard isUserInteractionEnabled || !event.isUserInteraction else {
			return
		}

		super.sendEvent(event)
	}

	override func responds(to selector: Selector!) -> Bool {
		// Deactivate toolbar interactions from the Main Menu.
		if selector == #selector(NSWindow.toggleToolbarShown(_:)) {
			return false
		}

		return super.responds(to: selector)
	}
}


@available(macOS 10.15, *)
extension View {
	/**
	Equivalent to `.eraseToAnyPublisher()` from the Combine framework.
	*/
	func eraseToAnyView() -> AnyView {
		AnyView(self)
	}
}
