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
	@Environment(\.colorScheme) var colorScheme
	@AppStorage(TerminalShellType.storageKey) var shellType: TerminalShellType = .default
	@AppStorage(TerminalFont.storageKey) var terminalFontSelection: TerminalFont = .default
	@AppStorage(TerminalFontName.storageKey) var terminalFontName: String = TerminalFontName.default
	@AppStorage(TerminalFontSize.storageKey) var terminalFontSize: Int = TerminalFontSize.default

	@StateObject private var ansiColors: AnsiColors = .shared

	// TODO: Persist this to not get a new terminal each time you switch file
	internal static var lastTerminal: LocalProcessTerminalView?
	@State internal var terminal: LocalProcessTerminalView

	private let systemFont: NSFont = .monospacedSystemFont(ofSize: 11, weight: .medium)

	private var font: NSFont {
		if terminalFontSelection == .systemFont {
			return systemFont
		}
		return NSFont(name: terminalFontName, size: CGFloat(terminalFontSize)) ?? systemFont
	}

	private var url: URL

	public init(url: URL) {
		self.url = url
		self._terminal = State(initialValue: TerminalEmulatorView.lastTerminal ?? .init(frame: .zero))
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
		switch shellType {
		case .auto:
			return autoDetectDefaultShell()
		case .bash:
			return "/bin/bash"
		case .zsh:
			return "/bin/zsh"
		}
	}

	/// Gets the default shell from the current user and returns the string of the shell path.
	private func autoDetectDefaultShell() -> String {
		let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
		guard bufsize != -1 else { return "/bin/bash" }
		let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
		defer {
			buffer.deallocate()
		}
		var pwd = passwd()
		var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)

		if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
		return String(cString: pwd.pw_shell)
	}

	/// Returns a reorderd array of ANSI colors depending on the app's color scheme (light/drak)
	private var appearanceColors: [SwiftTerm.Color] {
		if colorScheme == .dark {
			return colors
		}
		var col = colors
		col.move(fromOffsets: .init(integersIn: 0...7), toOffset: 16)
		return col
	}

	/// Returns the mapped array of `SwiftTerm.Color` objects of ANSI Colors
	private var colors: [SwiftTerm.Color] {
		return ansiColors.mappedColors.map { SwiftTerm.Color(hex: $0) }
	}

	/// Inherited from NSViewRepresentable.makeNSView(context:).
	public func makeNSView(context: Context) -> LocalProcessTerminalView {
		terminal.processDelegate = context.coordinator
		setupSession()
		return terminal
	}

	public func setupSession() {
		if TerminalEmulatorView.lastTerminal == nil {
			let shell = getShell()
			let shellIdiom = "-" + NSString(string: shell).lastPathComponent

			// changes working directory to project root
			// TODO: Get rid of FileManager shared instance to prevent problems
			// using shared instance of FileManager might lead to problems when using
			// multiple workspaces. This works for now but most probably will need
			// to be changed later on
			FileManager.default.changeCurrentDirectoryPath(url.path)
			terminal.startProcess(executable: shell, execName: shellIdiom)
			terminal.font = font
			terminal.configureNativeColors()
			terminal.installColors(self.appearanceColors)
		}
		TerminalEmulatorView.lastTerminal = terminal
	}

	public func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
		print("Update view")
//		if exited {
//			setupSession()
//		}
//		// if view.font != font { // Fixes Memory leak
//		// TODO: Fix memory leak
//		// for some reason setting the font here causes a memory leak.
//		// I'll leave it for now since the colors won't change
//		// without setting the font which is weird
//			view.font = font
//		// }
		view.configureNativeColors()
		view.installColors(self.appearanceColors)
		if TerminalEmulatorView.lastTerminal != nil {
			TerminalEmulatorView.lastTerminal = view
		}
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator()
	}
}
