import Cocoa

extension NSToolbarItem.Identifier {
	static let toolbarSegmentedControlItem = Self("toolbarSegmentedControlItem")
}

extension NSUserInterfaceItemIdentifier {
	static let toolbarSegmentedControl = Self("toolbarSegmentedControl")
}

final class SegmentedControlStyleViewController: NSViewController, PreferencesStyleController {
	var segmentedControl: NSSegmentedControl! {
		get { view as? NSSegmentedControl }
		set {
			view = newValue
		}
	}

	var isKeepingWindowCentered: Bool { true }

	weak var delegate: PreferencesStyleControllerDelegate?

	private var preferencePanes: [PreferencePane]!

	required init(preferencePanes: [PreferencePane]) {
		super.init(nibName: nil, bundle: nil)
		self.preferencePanes = preferencePanes
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = createSegmentedControl(preferencePanes: preferencePanes)
	}

	fileprivate func createSegmentedControl(preferencePanes: [PreferencePane]) -> NSSegmentedControl {
		let segmentedControl = NSSegmentedControl()
		segmentedControl.segmentCount = preferencePanes.count
		segmentedControl.segmentStyle = .texturedSquare
		segmentedControl.target = self
		segmentedControl.action = #selector(segmentedControlAction)
		segmentedControl.identifier = .toolbarSegmentedControl

		if let cell = segmentedControl.cell as? NSSegmentedCell {
			cell.controlSize = .regular
			cell.trackingMode = .selectOne
		}

		let segmentSize: CGSize = {
			let insets = CGSize(width: 36, height: 12)
			var maxSize = CGSize.zero

			for preferencePane in preferencePanes {
				let title = preferencePane.preferencePaneTitle
				let titleSize = title.size(
					withAttributes: [
						.font: NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
					]
				)

				maxSize = CGSize(
					width: max(titleSize.width, maxSize.width),
					height: max(titleSize.height, maxSize.height)
				)
			}

			return CGSize(
				width: maxSize.width + insets.width,
				height: maxSize.height + insets.height
			)
		}()

		let segmentBorderWidth = CGFloat(preferencePanes.count) + 1
		let segmentWidth = segmentSize.width * CGFloat(preferencePanes.count) + segmentBorderWidth
		let segmentHeight = segmentSize.height
		segmentedControl.frame = CGRect(x: 0, y: 0, width: segmentWidth, height: segmentHeight)

		for (index, preferencePane) in preferencePanes.enumerated() {
			segmentedControl.setLabel(preferencePane.preferencePaneTitle, forSegment: index)
			segmentedControl.setWidth(segmentSize.width, forSegment: index)
			if let cell = segmentedControl.cell as? NSSegmentedCell {
				cell.setTag(index, forSegment: index)
			}
		}

		return segmentedControl
	}

	@IBAction private func segmentedControlAction(_ control: NSSegmentedControl) {
		delegate?.activateTab(index: control.selectedSegment, animated: true)
	}

	func selectTab(index: Int) {
		segmentedControl.selectedSegment = index
	}

	func toolbarItemIdentifiers() -> [NSToolbarItem.Identifier] {
		[
			.flexibleSpace,
			.toolbarSegmentedControlItem,
			.flexibleSpace
		]
	}

	func toolbarItem(preferenceIdentifier: Preferences.PaneIdentifier) -> NSToolbarItem? {
		let toolbarItemIdentifier = preferenceIdentifier.toolbarItemIdentifier
		precondition(toolbarItemIdentifier == .toolbarSegmentedControlItem)

		// When the segments outgrow the window, we need to provide a group of
		// NSToolbarItems with custom menu item labels and action handling for the
		// context menu that pops up at the right edge of the window.
		let toolbarItemGroup = NSToolbarItemGroup(itemIdentifier: toolbarItemIdentifier)
		toolbarItemGroup.view = segmentedControl
		toolbarItemGroup.subitems = preferencePanes.enumerated().map { index, preferenceable -> NSToolbarItem in
			let item = NSToolbarItem(itemIdentifier: .init("segment-\(preferenceable.preferencePaneTitle)"))
			item.label = preferenceable.preferencePaneTitle

			let menuItem = NSMenuItem(
				title: preferenceable.preferencePaneTitle,
				action: #selector(segmentedControlMenuAction),
				keyEquivalent: ""
			)
			menuItem.tag = index
			menuItem.target = self
			item.menuFormRepresentation = menuItem

			return item
		}

		return toolbarItemGroup
	}

	@IBAction private func segmentedControlMenuAction(_ menuItem: NSMenuItem) {
		delegate?.activateTab(index: menuItem.tag, animated: true)
	}
}
