import Cocoa

extension NSApplication {
	/// Relaunch the app.
	func relaunch() {
		let configuration = NSWorkspace.OpenConfiguration()
		configuration.createsNewApplicationInstance = true

		NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: configuration) { _, _ in
			DispatchQueue.main.async {
				NSApp.terminate(nil)
			}
		}
	}
}
