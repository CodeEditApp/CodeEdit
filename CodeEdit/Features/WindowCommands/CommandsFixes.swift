//
//  CommandsFixes.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/03/2023.
//

import SwiftUI

extension EventModifiers {
    static var hiddenOption: EventModifiers = [.option, .numericPad]
}

extension NSMenuItem {

    static var value: URL?

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
    }

    static func swizzle() {
        let originalMethodSet = class_getInstanceMethod(self as AnyClass, #selector(setter: NSMenuItem.keyEquivalentModifierMask))
        let swizzledMethodSet = class_getInstanceMethod(self as AnyClass, #selector(fixAlternate))

        method_exchangeImplementations(originalMethodSet!, swizzledMethodSet!)
    }
}
