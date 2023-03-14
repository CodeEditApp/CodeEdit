//
//  NSApp+openWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/03/2023.
//

import AppKit

extension NSApplication {
    func openWindow(id: String) {
        NSMenuItem.openWindowAction = { (id, nil) }
        openWindowPerform()
    }

    func openWindow(id: String, value: any Codable & Hashable) {
        NSMenuItem.openWindowAction = { (id, value) }
        openWindowPerform()
    }

    func openWindow(value: any Codable & Hashable) {
        NSMenuItem.openWindowAction = { (nil, value) }
        openWindowPerform()
    }

    private func openWindowPerform() {
        let item = NSApp.windowsMenu?.items.first { $0.title == "OpenWindowAction" }
        if let item, let action = item.action {
            NSApp.sendAction(action, to: item.representedObject, from: nil)
        }
    }

    func closeWindow(id: String) {
        windows.first { $0.identifier?.rawValue == id }?.close()
    }

    func findWindow(id: String) -> NSWindow? {
        windows.first { $0.identifier?.rawValue == id }
    }

    var openSwiftUIWindows: Int {
        NSApp
            .windows
            .filter { $0.identifier?.rawValue == "Welcome" || $0.identifier?.rawValue == "About" }
            .count
    }
}
