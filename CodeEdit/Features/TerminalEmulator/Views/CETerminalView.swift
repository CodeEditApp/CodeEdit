//
//  CETerminalView.swift
//  CodeEdit
//
//  Created by Khan Winter on 7/11/25.
//

import SwiftTerm
import AppKit

/// # Please see dev note in ``CELocalShellTerminalView``!

class CETerminalView: TerminalView {
    override func setFrameSize(_ newSize: NSSize) {
        if newSize != .zero {
            super.setFrameSize(newSize)
        }
    }

    override open var frame: CGRect {
        get {
            super.frame
        }
        set {
            if newValue.size != .zero {
                super.frame = newValue
            }
        }
    }

    @objc
    override open func copy(_ sender: Any) {
        let range = selectedPositions()
        let text = terminal.getText(start: range.start, end: range.end)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    /// Clears the visible terminal contents and the scrollback buffer.
    ///
    /// Equivalent to Terminal.app / VS Code "Clear to Start" (⌘K). Operates on the
    /// emulator buffer only — nothing is sent to the shell process.
    ///
    /// Uses CSI sequences processed by SwiftTerm:
    /// - `CSI H` — move cursor home
    /// - `CSI 2 J` — erase the entire display
    /// - `CSI 3 J` — erase saved lines (scrollback)
    func clearToStart() {
        feed(text: "\u{001B}[H\u{001B}[2J\u{001B}[3J")
    }

    /// Intercepts ⌘K when ``SettingsData/TerminalSettings/clearToStartOnCommandK`` is enabled.
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard flags == .command,
              event.charactersIgnoringModifiers?.lowercased() == "k",
              Settings.shared.preferences.terminal.clearToStartOnCommandK else {
            return super.performKeyEquivalent(with: event)
        }

        clearToStart()
        return true
    }

    override open func isAccessibilityElement() -> Bool {
        true
    }

    override open func isAccessibilityEnabled() -> Bool {
        true
    }

    override open func accessibilityLabel() -> String? {
        "Terminal Emulator"
    }

    override open func accessibilityRole() -> NSAccessibility.Role? {
        .textArea
    }

    override open func accessibilityValue() -> Any? {
        terminal.getText(
            start: Position(col: 0, row: 0),
            end: Position(col: terminal.buffer.x, row: terminal.getTopVisibleRow() + terminal.rows)
        )
    }

    override open func accessibilitySelectedText() -> String? {
        let range = selectedPositions()
        let text = terminal.getText(start: range.start, end: range.end)
        return text
    }

}
