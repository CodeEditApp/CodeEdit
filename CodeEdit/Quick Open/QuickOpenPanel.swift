//
//  QuickOpenPanel.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 20.03.22.
//

import Cocoa

class QuickOpenPanel: NSPanel {
    override func standardWindowButton(_ button: NSWindow.ButtonType) -> NSButton? {
        let btn = super.standardWindowButton(button)
        btn?.isHidden = true
        return btn
    }
}
