//
//  CELocalShellTerminalView.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/7/24.
//

import AppKit
import SwiftTerm
import Foundation

/// # Dev Note (please read)
///
/// This entire file is a nearly 1:1 copy of SwiftTerm's `LocalProcessTerminalView`. The exception being the use of
/// `CETerminalView` over `TerminalView`. This change was made to fix the terminal clearing when the view was given a
/// frame of `0`. This enables terminals to keep running in the background, and allows them to be removed and added
/// back into the hierarchy for use in the utility area.
///
/// # 07/15/25
/// This has now been updated so that it differs from `LocalProcessTerminalView` in enough important ways that it
/// should not be removed in the future even if SwiftTerm has a change in behavior.

protocol CELocalShellTerminalViewDelegate: AnyObject {
    /// This method is invoked to notify that the terminal has been resized to the specified number of columns and rows
    /// the user interface code might try to adjust the containing scroll view, or if it is a top level window, the
    /// window itself
    /// - Parameter source: the sending instance
    /// - Parameter newCols: the new number of columns that should be shown
    /// - Parameter newRow: the new number of rows that should be shown
    func sizeChanged(source: CETerminalView, newCols: Int, newRows: Int)

    /// This method is invoked when the title of the terminal window should be updated to the provided title
    /// - Parameter source: the sending instance
    /// - Parameter title: the desired title
    func setTerminalTitle(source: CETerminalView, title: String)

    /// Invoked when the OSC command 7 for "current directory has changed" command is sent
    /// - Parameter source: the sending instance
    /// - Parameter directory: the new working directory
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?)

    /// This method will be invoked when the child process started by `startProcess` has terminated.
    /// - Parameter source: the local process that terminated
    /// - Parameter exitCode: the exit code returned by the process, or nil if this was an error caused during
    ///                       the IO reading/writing
    func processTerminated(source: TerminalView, exitCode: Int32?)
}

// MARK: - CELocalShellTerminalView

class CELocalShellTerminalView: CETerminalView, TerminalViewDelegate, LocalProcessDelegate {
    var process: LocalProcess!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    /// The `processDelegate` is used to deliver messages and information relevant to the execution of the terminal.
    public weak var processDelegate: CELocalShellTerminalViewDelegate?

    func setup() {
        terminal = Terminal(delegate: self, options: TerminalOptions(scrollback: 2000))
        terminalDelegate = self
        process = LocalProcess(delegate: self)
    }

    /// Launches a child process inside a pseudo-terminal.
    /// - Parameters:
    ///     - workspaceURL: The URL of the workspace to start at.
    ///     - shell: The shell to use, leave as `nil` to
    public func startProcess(
        workspaceURL url: URL?,
        shell: Shell? = nil,
        environment: [String] = [],
        interactive: Bool = true
    ) {
        let terminalSettings = Settings.shared.preferences.terminal

        var terminalEnvironment: [String] = Terminal.getEnvironmentVariables()
        terminalEnvironment.append("TERM_PROGRAM=CodeEditApp_Terminal")

        guard let (shell, shellPath) = getShell(shell, userSetting: terminalSettings.shell) else {
            return
        }

        processDelegate?.setTerminalTitle(source: self, title: shell.rawValue)

        do {
            let shellArgs: [String]
            if terminalSettings.useShellIntegration {
                shellArgs = try ShellIntegration.setUpIntegration(
                    for: shell,
                    environment: &terminalEnvironment,
                    useLogin: terminalSettings.useLoginShell,
                    interactive: interactive
                )
            } else {
                shellArgs = []
            }

            terminalEnvironment.append(contentsOf: environment)

            process.startProcess(
                executable: shellPath,
                args: shellArgs,
                environment: terminalEnvironment,
                execName: shell.rawValue,
                currentDirectory: url?.absolutePath
            )
        } catch {
            terminal.feed(text: "Failed to start a terminal session: \(error.localizedDescription)")
        }
    }

    /// Returns a string of a shell path to use
    func getShell(_ shellType: Shell?, userSetting: SettingsData.TerminalShell) -> (Shell, String)? {
        if let shellType {
            return (shellType, shellType.defaultPath)
        }
        switch userSetting {
        case .system:
            let defaultShell = Shell.autoDetectDefaultShell()
            guard let type = Shell(rawValue: NSString(string: defaultShell).lastPathComponent) else { return nil }
            return (type, defaultShell)
        case .bash:
            return (.bash, "/bin/bash")
        case .zsh:
            return (.zsh, "/bin/zsh")
        }
    }

    // MARK: - TerminalViewDelegate

    /// This method is invoked to notify the client of the new columsn and rows that have been set by the UI
    public func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        guard process.running else {
            return
        }
        var size = getWindowSize()
        _ = PseudoTerminalHelpers.setWinSize(masterPtyDescriptor: process.childfd, windowSize: &size)

        processDelegate?.sizeChanged(source: self, newCols: newCols, newRows: newRows)
    }

    public func clipboardCopy(source: TerminalView, content: Data) {
        if let str = String(bytes: content, encoding: .utf8) {
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.writeObjects([str as NSString])
        }
    }

    public func rangeChanged(source: TerminalView, startY: Int, endY: Int) { }

    /// Invoke this method to notify the processDelegate of the new title for the terminal window
    public func setTerminalTitle(source: TerminalView, title: String) {
        processDelegate?.setTerminalTitle(source: self, title: title)
    }

    public func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {
        processDelegate?.hostCurrentDirectoryUpdate(source: source, directory: directory)
    }

    /// Passes data from the terminal to the shell.
    /// Eg, the user types characters, this forwards the data to the shell.
    public func send(source: TerminalView, data: ArraySlice<UInt8>) {
        process.send(data: data)
    }

    public func scrolled(source: TerminalView, position: Double) { }

    // MARK: - LocalProcessDelegate

    /// Implements the LocalProcessDelegate method.
    public func processTerminated(_ source: LocalProcess, exitCode: Int32?) {
        processDelegate?.processTerminated(source: self, exitCode: exitCode)
    }

    /// Implements the LocalProcessDelegate.dataReceived method
    ///
    /// Passes data from the shell to the terminal.
    public func dataReceived(slice: ArraySlice<UInt8>) {
        feed(byteArray: slice)
    }

    /// Implements the LocalProcessDelegate.getWindowSize method
    public func getWindowSize() -> winsize {
        let frame: CGRect = self.frame
        return winsize(
            ws_row: UInt16(getTerminal().rows),
            ws_col: UInt16(getTerminal().cols),
            ws_xpixel: UInt16(frame.width),
            ws_ypixel: UInt16(frame.height)
        )
    }
}
