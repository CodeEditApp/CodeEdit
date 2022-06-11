//
//  NSTableView+Background.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 20.04.22.
//

import SwiftUI

extension NSTableView {
    /// Allows to set a lists background color in SwiftUI
    override open func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        backgroundColor = NSColor.clear
        enclosingScrollView?.drawsBackground = false
    }
}
