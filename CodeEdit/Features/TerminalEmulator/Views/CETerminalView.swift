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
