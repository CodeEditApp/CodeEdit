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

    @objc
    override open func copy(_ sender: Any) {
        let range = selectedPositions()
        let text = terminal.getText(start: range.start, end: range.end)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
}
