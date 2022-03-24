import Cocoa
import Preferences

extension Preferences.PaneIdentifier {
	static let general = Self("general")
	static let accounts = Self("accounts")
	static let advanced = Self("advanced")
}

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!

	private var preferencesStyle: Preferences.Style {
		get { .preferencesStyleFromUserDefaults() }
		set {
			newValue.storeInUserDefaults()
		}
	}

	private lazy var preferences: [PreferencePane] = [
		GeneralPreferenceViewController(),
		AccountsPreferenceViewController(),
		AdvancedPreferenceViewController()
	]

	private lazy var preferencesWindowController = PreferencesWindowController(
		preferencePanes: preferences,
		style: preferencesStyle,
		animated: true,
		hidesToolbarForSingleItem: true
	)

	func applicationWillFinishLaunching(_ notification: Notification) {
		window.orderOut(self)
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		preferencesWindowController.show(preferencePane: .accounts)
	}

	@IBAction private func preferencesMenuItemActionHandler(_ sender: NSMenuItem) {
		preferencesWindowController.show()
	}

	@IBAction private func switchStyle(_ sender: Any) {
		preferencesStyle = preferencesStyle == .segmentedControl
			? .toolbarItems
			: .segmentedControl

		NSApp.relaunch()
	}
}
