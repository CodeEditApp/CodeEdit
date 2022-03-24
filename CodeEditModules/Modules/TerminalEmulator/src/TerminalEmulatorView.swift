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

	private var terminal: LocalProcessTerminalView
	private var font: NSFont {
		if terminalFontSelection == .systemFont {
			return .monospacedSystemFont(ofSize: 11, weight: .medium)
		}
		return NSFont(name: terminalFontName, size: CGFloat(terminalFontSize)) ??
			.monospacedSystemFont(ofSize: 11, weight: .medium)
	}
	private var url: URL

	public init(url: URL) {
		self.url = url
		self.terminal = .init(frame: .zero)
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

	public func makeNSView(context: Context) -> LocalProcessTerminalView {
		terminal.processDelegate = context.coordinator

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
		return terminal
	}

	public func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
		view.configureNativeColors()
		view.installColors(self.appearanceColors)
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

	private var appearanceColors: [SwiftTerm.Color] {
		print(colorScheme)
		if colorScheme == .dark {
			return colors
		}
		var col = colors
		col.move(fromOffsets: .init(integersIn: 0...7), toOffset: 16)
		return col
	}

	private var colors: [SwiftTerm.Color] {
        guard let ansiColors = UserDefaults.standard.value(forKey: AnsiColors.storageKey) as? [Int] else {
            print("failed")
            return AnsiColors().mappedColors.map { SwiftTerm.Color(hex: $0) }
        }
        print("success")
        return ansiColors.map { SwiftTerm.Color(hex: $0) }
	}
}

extension SwiftTerm.Color {
	/// 0.0-1.0
	convenience init(dRed red: Double, green: Double, blue: Double) {
		let multiplier: Double = 65535
		self.init(red: UInt16(red * multiplier),
				  green: UInt16(green * multiplier),
				  blue: UInt16(blue * multiplier))
	}

	/// 0-255
	convenience init(iRed red: UInt8, green: UInt8, blue: UInt8) {
		let divisor: Double = 255
		self.init(dRed: Double(red) / divisor,
				  green: Double(green) / divisor,
				  blue: Double(blue) / divisor)
	}

    convenience init(hex: Int) {
        let red = UInt8((hex >> 16) & 0xFF)
        let green = UInt8((hex >> 8) & 0xFF)
        let blue = UInt8(hex & 0xFF)
        self.init(iRed: red, green: green, blue: blue)
    }
}
