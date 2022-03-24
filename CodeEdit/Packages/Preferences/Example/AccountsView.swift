import SwiftUI
import Preferences

// swiftlint:disable all

/**
Function wrapping SwiftUI into `PreferencePane`, which is mimicking view controller's default construction syntax.
*/
let AccountsPreferenceViewController: () -> PreferencePane = {
	/// Wrap your custom view into `Preferences.Pane`, while providing necessary toolbar info.
	let paneView = Preferences.Pane(
		identifier: .accounts,
		title: "Accounts",
		toolbarIcon: NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: "Accounts preferences")!
	) {
		AccountsView()
	}

	return Preferences.PaneHostingController(pane: paneView)
}

/**
The main view of “Accounts” preference pane.
*/
struct AccountsView: View {
	@State private var isOn1 = true
	@State private var isOn2 = false
	@State private var isOn3 = true
	@State private var selection1 = 1
	@State private var selection2 = 0
	@State private var selection3 = 0
	private let contentWidth: Double = 450.0

	var body: some View {
		Preferences.Container(contentWidth: contentWidth) {
			Preferences.Section(title: "Permissions:") {
				Toggle("Allow user to administer this computer", isOn: $isOn1)
				Text("Administrator has root access to this machine.")
					.preferenceDescription()
				Toggle("Allow user to access every file", isOn: $isOn2)
			}
			Preferences.Section(title: "Show scroll bars:") {
				Picker("", selection: $selection1) {
					Text("When scrolling").tag(0)
					Text("Always").tag(1)
				}
					.labelsHidden()
					.pickerStyle(RadioGroupPickerStyle())
			}
			Preferences.Section(label: {
				Toggle("Some toggle", isOn: $isOn3)
			}) {
				Picker("", selection: $selection2) {
					Text("Automatic").tag(0)
					Text("Manual").tag(1)
				}
					.labelsHidden()
					.frame(width: 120.0)
				Text("Automatic mode can slow things down.")
					.preferenceDescription()
			}
			Preferences.Section(title: "Preview mode:") {
				Picker("", selection: $selection3) {
					Text("Automatic").tag(0)
					Text("Manual").tag(1)
				}
					.labelsHidden()
					.frame(width: 120.0)
				Text("Automatic mode can slow things down.")
					.preferenceDescription()
			}
		}
	}
}

struct AccountsView_Previews: PreviewProvider {
	static var previews: some View {
		AccountsView()
	}
}
