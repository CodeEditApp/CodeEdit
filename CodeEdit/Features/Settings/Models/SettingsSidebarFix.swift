//
//  SettingsSidebarFix.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 13/04/2023.
//

import Foundation
import AppKit

extension NSSplitViewItem {
    @objc fileprivate var canCollapseSwizzled: Bool {
        if let check = self.viewController.view.window?.isSettingsWindow, check {
            return false
        }
        return self.canCollapseSwizzled
    }

    static func swizzle() {
        let origSelector = #selector(getter: NSSplitViewItem.canCollapse)
        let swizzledSelector = #selector(getter: canCollapseSwizzled)
        let originalMethodSet = class_getInstanceMethod(self as AnyClass, origSelector)
        let swizzledMethodSet = class_getInstanceMethod(self as AnyClass, swizzledSelector)

        // swiftlint:disable:next force_unwrapping
        method_exchangeImplementations(originalMethodSet!, swizzledMethodSet!)
    }
}
