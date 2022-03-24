import Cocoa

// swiftlint:disable all

final class PreferencesTabViewController: NSViewController, PreferencesStyleControllerDelegate {
	private var activeTab: Int?
	private var preferencePanes = [PreferencePane]()
	private var style: Preferences.Style?
	internal var preferencePanesCount: Int { preferencePanes.count }
	private var preferencesStyleController: PreferencesStyleController!
	private var isKeepingWindowCentered: Bool { preferencesStyleController.isKeepingWindowCentered }

	private var toolbarItemIdentifiers: [NSToolbarItem.Identifier] {
		preferencesStyleController?.toolbarItemIdentifiers() ?? []
	}

	var window: NSWindow! { view.window }

	var isAnimated = true

	var activeViewController: NSViewController? {
		guard let activeTab = activeTab else {
			return nil
		}

		return preferencePanes[activeTab]
	}

	override func loadView() {
		view = NSView()
		view.translatesAutoresizingMaskIntoConstraints = false
	}

	func configure(preferencePanes: [PreferencePane], style: Preferences.Style) {
		self.preferencePanes = preferencePanes
		self.style = style
		children = preferencePanes

		let toolbar = NSToolbar(identifier: "PreferencesToolbar")
		toolbar.allowsUserCustomization = false
		toolbar.displayMode = .iconAndLabel
		toolbar.showsBaselineSeparator = true
		toolbar.delegate = self

		switch style {
		case .segmentedControl:
			preferencesStyleController = SegmentedControlStyleViewController(preferencePanes: preferencePanes)
		case .toolbarItems:
			preferencesStyleController = ToolbarItemStyleViewController(
				preferencePanes: preferencePanes,
				toolbar: toolbar,
				centerToolbarItems: false
			)
		}
		preferencesStyleController.delegate = self

		// Called last so that `preferencesStyleController` can be asked for items.
		window.toolbar = toolbar
	}

	func activateTab(preferencePane: PreferencePane, animated: Bool) {
		activateTab(preferenceIdentifier: preferencePane.preferencePaneIdentifier, animated: animated)
	}

	func activateTab(preferenceIdentifier: Preferences.PaneIdentifier, animated: Bool) {
		guard let index = (preferencePanes.firstIndex { $0.preferencePaneIdentifier == preferenceIdentifier }) else {
			return activateTab(index: 0, animated: animated)
		}

		activateTab(index: index, animated: animated)
	}

	func activateTab(index: Int, animated: Bool) {
		defer {
			activeTab = index
			preferencesStyleController.selectTab(index: index)
			updateWindowTitle(tabIndex: index)
		}

		if activeTab == nil {
			immediatelyDisplayTab(index: index)
		} else {
			guard index != activeTab else {
				return
			}

			animateTabTransition(index: index, animated: animated)
		}
	}

	func restoreInitialTab() {
		if activeTab == nil {
			activateTab(index: 0, animated: false)
		}
	}

	private func updateWindowTitle(tabIndex: Int) {
		window.title = {
			if preferencePanes.count > 1 {
				return preferencePanes[tabIndex].preferencePaneTitle
			} else {
				let preferences = Localization[.preferences]
				let appName = Bundle.main.appName
				return "\(appName) \(preferences)"
			}
		}()
	}

	/// Cached constraints that pin `childViewController` views to the content view.
	private var activeChildViewConstraints = [NSLayoutConstraint]()

	private func immediatelyDisplayTab(index: Int) {
		let toViewController = preferencePanes[index]
		view.addSubview(toViewController.view)
		activeChildViewConstraints = toViewController.view.constrainToSuperviewBounds()
		setWindowFrame(for: toViewController, animated: false)
	}

	private func animateTabTransition(index: Int, animated: Bool) {
		guard let activeTab = activeTab else {
			assertionFailure("animateTabTransition called before a tab was displayed; transition only works from one tab to another")
			immediatelyDisplayTab(index: index)
			return
		}

		let fromViewController = preferencePanes[activeTab]
		let toViewController = preferencePanes[index]

		// View controller animations only work on macOS 10.14 and newer.
		let options: NSViewController.TransitionOptions
		if #available(macOS 10.14, *) {
			options = animated && isAnimated ? [.crossfade] : []
		} else {
			options = []
		}

		view.removeConstraints(activeChildViewConstraints)

		transition(
			from: fromViewController,
			to: toViewController,
			options: options
		) { [self] in
			activeChildViewConstraints = toViewController.view.constrainToSuperviewBounds()
		}
	}

	override func transition(
		from fromViewController: NSViewController,
		to toViewController: NSViewController,
		options: NSViewController.TransitionOptions = [],
		completionHandler completion: (() -> Void)? = nil
	) {
		let isAnimated = options
			.intersection([
				.crossfade,
				.slideUp,
				.slideDown,
				.slideForward,
				.slideBackward,
				.slideLeft,
				.slideRight
			])
			.isEmpty == false

		if isAnimated {
			NSAnimationContext.runAnimationGroup({ context in
				context.allowsImplicitAnimation = true
				context.duration = 0.25
				context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
				setWindowFrame(for: toViewController, animated: true)

				super.transition(
					from: fromViewController,
					to: toViewController,
					options: options,
					completionHandler: completion
				)
			}, completionHandler: nil)
		} else {
			super.transition(
				from: fromViewController,
				to: toViewController,
				options: options,
				completionHandler: completion
			)
		}
	}

	private func setWindowFrame(for viewController: NSViewController, animated: Bool = false) {
		guard let window = window else {
			preconditionFailure()
		}

		let contentSize = viewController.view.fittingSize

		let newWindowSize = window.frameRect(forContentRect: CGRect(origin: .zero, size: contentSize)).size
		var frame = window.frame
		frame.origin.y += frame.height - newWindowSize.height
		frame.size = newWindowSize

		if isKeepingWindowCentered {
			let horizontalDiff = (window.frame.width - newWindowSize.width) / 2
			frame.origin.x += horizontalDiff
		}

		let animatableWindow = animated ? window.animator() : window
		animatableWindow.setFrame(frame, display: false)
	}
}

extension PreferencesTabViewController: NSToolbarDelegate {
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		toolbarItemIdentifiers
	}

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		toolbarItemIdentifiers
	}

	func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		style == .segmentedControl ? [] : toolbarItemIdentifiers
	}

	public func toolbar(
		_ toolbar: NSToolbar,
		itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
		willBeInsertedIntoToolbar flag: Bool
	) -> NSToolbarItem? {
		if itemIdentifier == .flexibleSpace {
			return nil
		}

		return preferencesStyleController.toolbarItem(preferenceIdentifier: Preferences.PaneIdentifier(fromToolbarItemIdentifier: itemIdentifier))
	}
}
