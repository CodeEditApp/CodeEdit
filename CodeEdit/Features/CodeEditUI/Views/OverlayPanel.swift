//
//  OverlayPanel.swift
//  CodeEditModules/CodeEditUI
//
//  Created by Pavel Kasila on 20.03.22.
//

import Cocoa

final class OverlayPanel: NSPanel, NSWindowDelegate {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 48),
            styleMask: [.fullSizeContentView, .titled, .resizable],
            backing: .buffered, defer: false)
        self.delegate = self
        self.center()
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true
    }

    override func standardWindowButton(_ button: NSWindow.ButtonType) -> NSButton? {
        let btn = super.standardWindowButton(button)
        btn?.isHidden = true
        return btn
    }

    func windowDidResignKey(_ notification: Notification) {
        if let panel = notification.object as? OverlayPanel {
            panel.close()
        }
    }
}
