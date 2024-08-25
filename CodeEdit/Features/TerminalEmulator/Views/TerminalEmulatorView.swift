//
//  TerminalEmulatorView.swift
//  CodeEditModules/TerminalEmulator
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
/// Caches the view in the ``TerminalCache`` to keep terminal state when the view is removed from the hierarchy.
///
struct TerminalEmulatorView: NSViewRepresentable {
    @AppSettings(\.terminal)
    var terminalSettings
    @AppSettings(\.textEditing.font)
    var fontSettings

    @StateObject private var themeModel: ThemeModel = .shared

    private var font: NSFont {
        if terminalSettings.useTextEditorFont {
            return fontSettings.current
        } else {
            return terminalSettings.font.current
        }
    }

    private let terminalID: UUID
    private var url: URL

    public var shellType: Shell?
    public var onTitleChange: (_ title: String) -> Void

    /// Create an emulator view
    /// - Parameters:
    ///   - url: The URL the emulator should start at.
    ///   - terminalID: The ID of the terminal. Used to restore state when switching away from the view.
    ///   - shellType: The type of shell to use. Overrides any settings or auto-detection.
    ///   - onTitleChange: A callback used when the terminal updates it's title.
    init(url: URL, terminalID: UUID, shellType: Shell? = nil, onTitleChange: @escaping (_ title: String) -> Void) {
        self.url = url
        self.terminalID = terminalID
        self.shellType = shellType
        self.onTitleChange = onTitleChange
    }

    // MARK: - Settings

    /// Returns a string of a shell path to use
    private func getShell() -> String {
        if let shellType {
            return shellType.defaultPath
        }
        switch terminalSettings.shell {
        case .system:
            return Shell.autoDetectDefaultShell()
        case .bash:
            return "/bin/bash"
        case .zsh:
            return "/bin/zsh"
        }
    }

    private func getTerminalCursor() -> CursorStyle {
            let blink = terminalSettings.cursorBlink
            switch terminalSettings.cursorStyle {
            case .block:
                return blink ? .blinkBlock : .steadyBlock
            case .underline:
                return blink ? .blinkUnderline : .steadyUnderline
            case .bar:
                return blink ? .blinkBar : .steadyBar
            }
    }

    /// Returns true if the `option` key should be treated as the `meta` key.
    private var optionAsMeta: Bool {
        terminalSettings.optionAsMeta
    }

    /// Returns the mapped array of `SwiftTerm.Color` objects of ANSI Colors
    private var colors: [SwiftTerm.Color] {
        if let selectedTheme = Settings[\.theme].matchAppearance && Settings[\.terminal].darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return themeModel.themes[index].terminal.ansiColors.map { color in
                SwiftTerm.Color(hex: color)
            }
        }
        return []
    }

    /// Returns the `cursor` color of the selected theme
    private var cursorColor: NSColor {
        if let selectedTheme = Settings[\.theme].matchAppearance && Settings[\.terminal].darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.cursor.swiftColor)
        }
        return NSColor(.accentColor)
    }

    /// Returns the `selection` color of the selected theme
    private var selectionColor: NSColor {
        if let selectedTheme = Settings[\.theme].matchAppearance && Settings[\.terminal].darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.selection.swiftColor)
        }
        return NSColor(.accentColor)
    }

    /// Returns the `text` color of the selected theme
    private var textColor: NSColor {
        if let selectedTheme = Settings[\.theme].matchAppearance && Settings[\.terminal].darkAppearance
            ? themeModel.selectedDarkTheme
            : themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.text.swiftColor)
        }
        return NSColor(.primary)
    }

    /// Returns the `background` color of the selected theme
    private var backgroundColor: NSColor {
        return .clear
    }

    /// returns a `NSAppearance` based on the user setting of the terminal appearance,
    /// `nil` if app default is not overridden
    private var colorAppearance: NSAppearance? {
        if terminalSettings.darkAppearance {
            return .init(named: .darkAqua)
        }
        return nil
    }

    // MARK: - NSViewRepresentable

    /// Inherited from NSViewRepresentable.makeNSView(context:).
    func makeNSView(context: Context) -> CELocalProcessTerminalView {
        let terminalExists = TerminalCache.shared.getTerminalView(terminalID) != nil
        let view = TerminalCache.shared.getTerminalView(terminalID) ?? CELocalProcessTerminalView(frame: .zero)
        view.processDelegate = context.coordinator
        if !terminalExists { // New terminal, start the shell process.
            do {
                try setupSession(view)
            } catch {
                view.feed(text: "Failed to start a terminal session: \(error.localizedDescription)")
            }
            configureView(view)
        }
        TerminalCache.shared.cacheTerminalView(for: terminalID, view: view)
        return view
    }

    /// Setup a new shell process.
    /// - Parameter terminal: The terminal view to set up.
    func setupSession(_ terminal: CELocalProcessTerminalView) throws {
        // changes working directory to project root
        // TODO: Get rid of FileManager shared instance to prevent problems
        // using shared instance of FileManager might lead to problems when using
        // multiple workspaces. This works for now but most probably will need
        // to be changed later on
        FileManager.default.changeCurrentDirectoryPath(url.path)

        var terminalEnvironment: [String] = Terminal.getEnvironmentVariables()
        terminalEnvironment.append("TERM_PROGRAM=CodeEditApp_Terminal")

        let shellPath = getShell()
        guard let shell = Shell(rawValue: NSString(string: shellPath).lastPathComponent) else {
            return
        }
        onTitleChange(shell.rawValue)

        let shellArgs: [String]
        if terminalSettings.useShellIntegration {
            shellArgs = try ShellIntegration.setUpIntegration(
                for: shell,
                environment: &terminalEnvironment,
                useLogin: terminalSettings.useLoginShell
            )
        } else {
            shellArgs = []
        }

        terminal.startProcess(
            executable: shellPath,
            args: shellArgs,
            environment: terminalEnvironment,
            execName: shell.rawValue
        )
        terminal.font = font
        terminal.configureNativeColors()
        terminal.installColors(self.colors)
        terminal.caretColor = cursorColor.withAlphaComponent(0.5)
        terminal.caretTextColor = cursorColor.withAlphaComponent(0.5)
        terminal.selectedTextBackgroundColor = selectionColor
        terminal.nativeForegroundColor = textColor
        terminal.nativeBackgroundColor = terminalSettings.useThemeBackground ? backgroundColor : .clear
        terminal.cursorStyleChanged(source: terminal.getTerminal(), newStyle: getTerminalCursor())
        terminal.layer?.backgroundColor = .clear
        terminal.optionAsMetaKey = optionAsMeta
    }

    func configureView(_ terminal: CELocalProcessTerminalView) {
        terminal.getTerminal().silentLog = true
        terminal.appearance = colorAppearance
        scroller(terminal)?.isHidden = true
    }

    private func scroller(_ terminal: CELocalProcessTerminalView) -> NSScroller? {
        for subView in terminal.subviews {
            if let scroller = subView as? NSScroller {
                return scroller
            }
        }
        return nil
    }

    func updateNSView(_ view: CELocalProcessTerminalView, context: Context) {
        view.configureNativeColors()
        view.installColors(self.colors)
        view.caretColor = cursorColor.withAlphaComponent(0.5)
        view.caretTextColor = cursorColor.withAlphaComponent(0.5)
        view.selectedTextBackgroundColor = selectionColor
        view.nativeForegroundColor = textColor
        view.nativeBackgroundColor = terminalSettings.useThemeBackground ? backgroundColor : .clear
        view.layer?.backgroundColor = .clear
        view.optionAsMetaKey = optionAsMeta
        view.cursorStyleChanged(source: view.getTerminal(), newStyle: getTerminalCursor())
        view.appearance = colorAppearance
        view.getTerminal().softReset()
        view.feed(text: "") // send empty character to force colors to be redrawn
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(terminalID: terminalID, onTitleChange: onTitleChange)
    }
}
