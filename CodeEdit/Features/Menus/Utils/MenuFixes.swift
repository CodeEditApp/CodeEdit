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

    /// Helper variable to allow opening SwiftUI windows from anywhere in the app.
    /// Don't use this, unless you know what you're doing.
    static var openWindowAction: (() -> (SceneID?, (any Codable & Hashable)?))?

    @objc
    fileprivate func fixAlternate(_ newValue: NSEvent.ModifierFlags) {

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
        let origSelector = #selector(setter: NSMenuItem.keyEquivalentModifierMask)
        let swizzledSelector = #selector(fixAlternate)
        let originalMethodSet = class_getInstanceMethod(self as AnyClass, origSelector)
        let swizzledMethodSet = class_getInstanceMethod(self as AnyClass, swizzledSelector)

        method_exchangeImplementations(originalMethodSet!, swizzledMethodSet!)
    }
}
