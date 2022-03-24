import Cocoa

protocol PreferencesStyleController: AnyObject {
	var delegate: PreferencesStyleControllerDelegate? { get set }
	var isKeepingWindowCentered: Bool { get }

	func toolbarItemIdentifiers() -> [NSToolbarItem.Identifier]
	func toolbarItem(preferenceIdentifier: Preferences.PaneIdentifier) -> NSToolbarItem?
	func selectTab(index: Int)
}

protocol PreferencesStyleControllerDelegate: AnyObject {
	func activateTab(preferenceIdentifier: Preferences.PaneIdentifier, animated: Bool)
	func activateTab(index: Int, animated: Bool)
}
