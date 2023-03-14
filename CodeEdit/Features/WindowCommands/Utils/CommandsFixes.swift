//
//  CommandsFixes.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

extension EventModifiers {
    static var hidden: EventModifiers = .numericPad
}

extension NSMenuItem {

    static var openWindowAction: (() -> (String?, (any Codable & Hashable)?))?

    @objc
    func fixAlternate(_ newValue: NSEvent.ModifierFlags) {

        if newValue.contains(.numericPad) {
            isAlternate = true
            fixAlternate(newValue.subtracting(.numericPad))
        }

        fixAlternate(newValue)

        if self.title == "Open Recent" {
            let openRecentMenu = NSMenu(title: "Open Recent")
            openRecentMenu.perform(NSSelectorFromString("_setMenuName:"), with: "NSRecentDocumentsMenu")
            self.submenu = openRecentMenu
            NSDocumentController.shared.value(forKey: "_installOpenRecentMenus")
        }

        if self.title == "OpenWindowAction" || self.title.isEmpty {
            self.isHidden = true
            self.allowsKeyEquivalentWhenHidden = true
        }
    }

    static func swizzle() {
        let originalMethodSet = class_getInstanceMethod(self as AnyClass, #selector(setter: NSMenuItem.keyEquivalentModifierMask))
        let swizzledMethodSet = class_getInstanceMethod(self as AnyClass, #selector(fixAlternate))

        method_exchangeImplementations(originalMethodSet!, swizzledMethodSet!)
    }
}

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
}
