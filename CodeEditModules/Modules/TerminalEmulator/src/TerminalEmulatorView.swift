//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI
import SwiftTerm
import AppPreferences

/// # TerminalEmulatorView
///
/// A terminal emulator view.
///
/// Wraps a `LocalProcessTerminalView` from `SwiftTerm` inside a `NSViewRepresentable`
/// for use in SwiftUI.
///
public struct TerminalEmulatorView: NSViewRepresentable {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @StateObject
    private var themeModel: ThemeModel = .shared

    internal static var lastTerminal: LocalProcessTerminalView?

    @State
    internal var terminal: LocalProcessTerminalView

    private let systemFont: NSFont = .monospacedSystemFont(ofSize: 11, weight: .medium)

    private var font: NSFont {
        if !prefs.preferences.terminal.font.customFont {
            return systemFont
        }
        return NSFont(
            name: prefs.preferences.terminal.font.name,
            size: CGFloat(prefs.preferences.terminal.font.size)
        ) ?? systemFont
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
    ///    let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
    ///    guard bufsize != -1 else { return "/bin/bash" }
    ///    let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
    /// defer {
    ///        buffer.deallocate()
    ///    }
    ///    var pwd = passwd()
    ///    var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)
    ///
    /// if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
    ///    return String(cString: pwd.pw_shell)
    /// ```
    private func getShell() -> String {
        switch prefs.preferences.terminal.shell {
        case .system:
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

    /// Returns the mapped array of `SwiftTerm.Color` objects of ANSI Colors
    private var colors: [SwiftTerm.Color] {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return themeModel.themes[index].terminal.ansiColors.map { color in
                SwiftTerm.Color(hex: color)
            }
        }
        return []
    }

    /// returns a `NSAppearance` based on the user setting of the terminal appearance,
    /// `nil` if app default is not overriden
    private var colorAppearance: NSAppearance? {
        if prefs.preferences.terminal.darkAppearance {
            return .init(named: .darkAqua)
        }
        return nil
    }

    /// Inherited from NSViewRepresentable.makeNSView(context:).
    public func makeNSView(context: Context) -> LocalProcessTerminalView {
        terminal.processDelegate = context.coordinator
        setupSession()
        return terminal
    }

    public func setupSession() {
        terminal.getTerminal().silentLog = true
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
            terminal.installColors(self.colors)
        }
        terminal.appearance = colorAppearance
        TerminalEmulatorView.lastTerminal = terminal
    }

    public func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
        if view.font != font { // Fixes Memory leak
            view.font = font
        }
        view.configureNativeColors()
        view.installColors(self.colors)
        view.appearance = colorAppearance
        if TerminalEmulatorView.lastTerminal != nil {
            TerminalEmulatorView.lastTerminal = view
        }
        view.getTerminal().softReset()
        view.feed(text: "") // send empty character to force colors to be redrawn
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}
