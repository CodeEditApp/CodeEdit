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
struct TerminalEmulatorView: NSViewRepresentable {
    @AppSettings(\.terminal)
    var terminalSettings
    @AppSettings(\.textEditing.font)
    var fontSettings

    @StateObject private var themeModel: ThemeModel = .shared

    static var lastTerminal: [String: LocalProcessTerminalView] = [:]

    @State var terminal: LocalProcessTerminalView

    private let systemFont: NSFont = .monospacedSystemFont(ofSize: 11, weight: .medium)

    private var font: NSFont {
        if terminalSettings.useTextEditorFont {
            if !fontSettings.customFont {
                return systemFont.withSize(CGFloat(fontSettings.size))
            }
            return NSFont(
                name: fontSettings.name,
                size: CGFloat(fontSettings.size)
            ) ?? systemFont
        }

        if !terminalSettings.font.customFont {
            return systemFont.withSize(CGFloat(terminalSettings.font.size))
        }
        return NSFont(
            name: terminalSettings.font.name,
            size: CGFloat(terminalSettings.font.size)
        ) ?? systemFont
    }

    private var url: URL

    public var shellType: String

    public var onTitleChange: (_ title: String) -> Void

    init(url: URL, shellType: String? = nil, onTitleChange: @escaping (_ title: String) -> Void) {
        self.url = url
        self.shellType = shellType ?? ""
        self.onTitleChange = onTitleChange
        self._terminal = State(initialValue: TerminalEmulatorView.lastTerminal[url.path] ?? .init(frame: .zero))
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
        if shellType != ""{
            return shellType
        }
        switch terminalSettings.shell {
        case .system:
            return autoDetectDefaultShell()
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

    /// Check if the source command for shell integration already exists
    /// Returns true if it already exists or encountered an error, no new commands will be added to user's source file
    /// Returns false if it's not there, new commands will be added to user's source file
    private func shellIntegrationInstalled(sourceScriptPath: String, command: String) -> Bool {
        do {
            // Get user's shell's source file
            let sourceScript = try String(contentsOfFile: sourceScriptPath)
            let sourceScriptSeperatedByLines = sourceScript.components(separatedBy: .newlines)
            // Check line by line
            for line in sourceScriptSeperatedByLines where line == command {
                // If one line matches the command, no new commands are needed
                return true
            }
            // If no line matches the command, new command is needed
            return false
        } catch {
            if let error = error as NSError? {
                switch error._code {
                case 260:
                    // If error 260 is thrown, it's just the source file is missing
                    // Create a new file and add new command
                    FileManager.default.createFile(atPath: sourceScriptPath, contents: nil, attributes: nil)
                    return false
                default:
                    // Otherwise just abort the shell integration setup
                    print("Cannot setup shell integration, error: \(error)")
                    return true
                }
            }
        }
    }

    /// Configure shell integration script
    private func setupShellIntegration(shell: String, environment: [String]) {
        // Get user's home dir
        var homePath: String = ""
        environment.forEach { value in
            if value.starts(with: "HOME=") {
                homePath = value
            }
        }
        homePath.removeSubrange(homePath.startIndex..<homePath.index(homePath.startIndex, offsetBy: 5))

        if let shellIntegrationScript = Bundle.main.url(
            forResource: "codeedit_shell_integration", withExtension: shell
        ) {
            // Get the path of shell integration script
            let shellIntegrationScriptPath = (
                shellIntegrationScript.absoluteString[7..<shellIntegrationScript.absoluteString.count]
            ) ?? ""

            // Get the path of user's shell's source file
            // Only zsh and bash are supported for now
            var sourceScriptPath: String = ""
            switch shell {
            case "bash":
                sourceScriptPath = homePath + "/.profile"
            case "zsh":
                sourceScriptPath = homePath + "/.zshrc"
            default:
                return
            }

            // Get the command for setting up shell integration
            let sourceCommand = "[[ \"$TERM_PROGRAM\" == \"CodeEditApp_Terminal\" ]] &&"
                            + " . \"\(shellIntegrationScriptPath)\""

            // Add the shell integration setup command if needed
            if !shellIntegrationInstalled(sourceScriptPath: sourceScriptPath, command: sourceCommand) {
                if let handle = FileHandle(forWritingAtPath: sourceScriptPath) {
                    handle.seekToEndOfFile()
                    handle.write("\n\(sourceCommand)\n".data(using: .utf8)!)
                    handle.closeFile()
                }
            }
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

    /// Inherited from NSViewRepresentable.makeNSView(context:).
    func makeNSView(context: Context) -> LocalProcessTerminalView {
        terminal.processDelegate = context.coordinator
        setupSession()
        return terminal
    }

    func setupSession() {
        terminal.getTerminal().silentLog = true
        if TerminalEmulatorView.lastTerminal[url.path] == nil {
            let shell = getShell()
            let shellName = NSString(string: shell).lastPathComponent
            onTitleChange(shellName)
            let shellIdiom = "-" + shellName

            // changes working directory to project root
            // TODO: Get rid of FileManager shared instance to prevent problems
            // using shared instance of FileManager might lead to problems when using
            // multiple workspaces. This works for now but most probably will need
            // to be changed later on
            FileManager.default.changeCurrentDirectoryPath(url.path)

            var terminalEnvironment: [String] = Terminal.getEnvironmentVariables()
            terminalEnvironment.append("TERM_PROGRAM=CodeEditApp_Terminal")

            setupShellIntegration(shell: shellName, environment: terminalEnvironment)

            terminal.startProcess(executable: shell, environment: terminalEnvironment, execName: shellIdiom)
            terminal.font = font
            terminal.configureNativeColors()
            terminal.installColors(self.colors)
            terminal.caretColor = cursorColor
            terminal.selectedTextBackgroundColor = selectionColor
            terminal.nativeForegroundColor = textColor
            terminal.nativeBackgroundColor = terminalSettings.useThemeBackground ? backgroundColor : .clear
            terminal.cursorStyleChanged(source: terminal.getTerminal(), newStyle: getTerminalCursor())
            terminal.layer?.backgroundColor = .clear
            terminal.optionAsMetaKey = optionAsMeta
        }
        terminal.appearance = colorAppearance
        scroller?.isHidden = true
        TerminalEmulatorView.lastTerminal[url.path] = terminal
    }

    private var scroller: NSScroller? {
        for subView in terminal.subviews {
            if let scroller = subView as? NSScroller {
                return scroller
            }
        }
        return nil
    }

    func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
        if view.font != font { // Fixes Memory leak
            view.font = font
        }
        view.configureNativeColors()
        view.installColors(self.colors)
        view.caretColor = cursorColor
        view.selectedTextBackgroundColor = selectionColor
        view.nativeForegroundColor = textColor
        view.nativeBackgroundColor = terminalSettings.useThemeBackground ? backgroundColor : .clear
        view.layer?.backgroundColor = .clear
        view.optionAsMetaKey = optionAsMeta
        view.cursorStyleChanged(source: view.getTerminal(), newStyle: getTerminalCursor())
        view.appearance = colorAppearance
        if TerminalEmulatorView.lastTerminal[url.path] != nil {
            TerminalEmulatorView.lastTerminal[url.path] = view
        }
        view.getTerminal().softReset()
        view.feed(text: "") // send empty character to force colors to be redrawn
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url, onTitleChange: onTitleChange)
    }
}
