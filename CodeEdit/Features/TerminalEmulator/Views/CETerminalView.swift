//
//  CETerminalView.swift
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
/// If there is a bug here: **there probably isn't**. Look instead in ``TerminalEmulatorView``.

class CETerminalView: TerminalView {
    override var frame: NSRect {
        get {
            return super.frame
        }
        set(newValue) {
            if newValue != .zero {
                super.frame = newValue
            }
        }
    }
}

protocol CELocalProcessTerminalViewDelegate: AnyObject {
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
    func hostCurrentDirectoryUpdate (source: TerminalView, directory: String?)

    /// This method will be invoked when the child process started by `startProcess` has terminated.
    /// - Parameter source: the local process that terminated
    /// - Parameter exitCode: the exit code returned by the process, or nil if this was an error caused during
    ///                       the IO reading/writing
    func processTerminated (source: TerminalView, exitCode: Int32?)
}

class CELocalProcessTerminalView: CETerminalView, TerminalViewDelegate, LocalProcessDelegate {
    var process: LocalProcess!

    override public init (frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init? (coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup () {
        terminalDelegate = self
        process = LocalProcess(delegate: self)
    }

    /// The `processDelegate` is used to deliver messages and information relevant to the execution of the terminal.
    public weak var processDelegate: CELocalProcessTerminalViewDelegate?

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

    /// This method is invoked when input from the user needs to be sent to the client
    public func send(source: TerminalView, data: ArraySlice<UInt8>) {
        process.send(data: data)
    }

    /// Use this method to toggle the logging of data coming from the host, or pass nil to stop
    public func setHostLogging (directory: String?) {
        process.setHostLogging(directory: directory)
    }

    public func scrolled(source: TerminalView, position: Double) { }

    /// Launches a child process inside a pseudo-terminal.
    /// - Parameter executable: The executable to launch inside the pseudo terminal, defaults to /bin/bash
    /// - Parameter args: an array of strings that is passed as the arguments to the underlying process
    /// - Parameter environment: an array of environment variables to pass to the child process, if this is null,
    ///                          this picks a good set of defaults from `Terminal.getEnvironmentVariables`.
    /// - Parameter execName: If provided, this is used as the Unix argv[0] parameter,
    ///                       otherwise, the executable is used as the args [0], this is used when
    ///                       the intent is to set a different process name than the file that backs it.
    public func startProcess(
        executable: String = "/bin/bash",
        args: [String] = [],
        environment: [String]? = nil,
        execName: String? = nil
    ) {
        process.startProcess(executable: executable, args: args, environment: environment, execName: execName)
    }

    /// Implements the LocalProcessDelegate method.
    public func processTerminated(_ source: LocalProcess, exitCode: Int32?) {
        processDelegate?.processTerminated(source: self, exitCode: exitCode)
    }

    /// Implements the LocalProcessDelegate.dataReceived method
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
