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

	public init() {
		terminal = .init(frame: .zero)
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
		return "/bin/bash" // can be changed to "/bin/zsh"
	}

	public func makeNSView(context: Context) -> LocalProcessTerminalView {
		terminal.processDelegate = context.coordinator
		terminal.feed(text: "Hello World")

		let shell = getShell()
		let shellIdiom = "-" + NSString(string: shell).lastPathComponent

		terminal.startProcess(executable: shell, execName: shellIdiom)
		terminal.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)

		terminal.configureNativeColors()
		return terminal
	}

	public func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
		view.configureNativeColors()
	}

	public func makeCoordinator() -> Coordinator {
		return Coordinator()
	}

	public class Coordinator: NSObject, LocalProcessTerminalViewDelegate {
		public override init() {}

		public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

		public func sizeChanged(source: LocalProcessTerminalView, newCols: Int, newRows: Int) {}

		public func setTerminalTitle(source: LocalProcessTerminalView, title: String) {}

		public func processTerminated(source: TerminalView, exitCode: Int32?) {}
	}
}
