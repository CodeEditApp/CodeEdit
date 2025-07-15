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
}
