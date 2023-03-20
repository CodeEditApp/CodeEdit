//
//  NSApp+openWindow.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/03/2023.
//

import AppKit

extension NSApplication {
    func openWindow(_ id: SceneID) {
        NSMenuItem.openWindowAction = { (id, nil) }
        openWindowPerform()
    }

    func openWindow(_ id: SceneID, value: any Codable & Hashable) {
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

    func closeWindow(_ id: SceneID) {
        windows.first { $0.identifier?.rawValue == id.rawValue }?.close()
    }

    func closeWindow(_ ids: SceneID...) {
        ids.forEach { id in
            windows.first { $0.identifier?.rawValue == id.rawValue }?.close()
        }
    }

    func findWindow(_ id: SceneID) -> NSWindow? {
        windows.first { $0.identifier?.rawValue == id.rawValue }
    }

    var openSwiftUIWindows: Int {
        NSApp
            .windows
            .compactMap(\.identifier?.rawValue)
            .compactMap { SceneID(rawValue: $0) }
            .count
    }
}
