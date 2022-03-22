//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import SwiftTerm

/// # TerminalEmulatorView
///
/// A terminal emulator view.
///
/// Wraps a `LocalProcessTerminalView` from `SwiftTerm` inside a `NSViewRepresentable`
/// for use in SwiftUI.
///
public struct TerminalEmulatorView: NSViewRepresentable {

	private var terminal: LocalProcessTerminalView
	private var font: NSFont
	private var url: URL

	public init(url: URL, font: NSFont = .monospacedSystemFont(ofSize: 12, weight: .medium)) {
		self.url = url
		self.terminal = .init(frame: .zero)
		self.font = font
	}

	/// Returns a string of a shell path to use
	///
	/// Default implementation pulled from Example app from "SwiftTerm":
	/// ```swift
	///	let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
	///	guard bufsize != -1 else { return "/bin/bash" }
	///	let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
	/// defer {
	///		buffer.deallocate()
	///	}
	///	var pwd = passwd()
	///	var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)
	///
	/// if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
	///	return String(cString: pwd.pw_shell)
	/// ```
	private func getShell() -> String {
		"/bin/bash" // can be changed to "/bin/zsh"
	}

	public func makeNSView(context: Context) -> LocalProcessTerminalView {
		terminal.processDelegate = context.coordinator

		let shell = getShell()
		let shellIdiom = "-" + NSString(string: shell).lastPathComponent

		// changes working directory to project root
		FileManager.default.changeCurrentDirectoryPath(url.path)
		terminal.startProcess(executable: shell, execName: shellIdiom)
		terminal.font = font
		terminal.feed(text: "")
		terminal.configureNativeColors()
		return terminal
	}

	public func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
		view.configureNativeColors()
		view.font = font
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	public class Coordinator: NSObject, LocalProcessTerminalViewDelegate {
		public override init() {}

		public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

		public func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

		public func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}

		public func processTerminated(source: TerminalView, exitCode: Int32?) {}
	}
}
