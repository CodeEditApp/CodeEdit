//
//  SplitViewSwizzling.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/01/2023.
//

import SwiftUI

// This filters out the default Sidebar Toggle ToolbarItem.
extension NSToolbar {

    @objc var itemsSwizzled: [NSToolbarItem] {
        self.itemsSwizzled.filter { $0.itemIdentifier.rawValue != "com.apple.SwiftUI.navigationSplitView.toggleSidebar" }
    }

    static func swizzle() {
        swizzle(#selector (getter: items), #selector (getter: itemsSwizzled))
    }
}

// This will set the last column in a 3-column NavigationSplitView to an inspector state.
extension NSSplitViewController {

    @objc func setItemsSwizzled(_ newValue: [NSSplitViewItem]) {
        if newValue.count == 3, let inspector = newValue.last {
            inspector.minimumThickness = 150
            inspector.maximumThickness = 500
            inspector.allowsFullHeightLayout = true
            inspector.titlebarSeparatorStyle = .none
            inspector.canCollapse = true
            inspector.holdingPriority = newValue[0].holdingPriority
        }

        setItemsSwizzled(newValue)
    }

    static func swizzle() {
        swizzle(#selector (setter: NSSplitViewController.splitViewItems), #selector (NSSplitViewController.setItemsSwizzled))
    }
}

// This will fix a SwiftUI bug where the window toolbar has an incorrect color.
extension NSVisualEffectView {

    @objc func setMaterialSwizzled(_ newValue: Material) {
        if let superview = self.superview, superview.className == "NSTitlebarView" {
            if superview.subviews.map(\.className).filter { $0 == "NSVisualEffectView" }.count == 3 && superview.subviews.first == self {
                setMaterialSwizzled(.hudWindow)
                return
            }
        }
        setMaterialSwizzled(newValue)
    }

    static func swizzle() {
        swizzle(#selector(setter: material), #selector(setMaterialSwizzled))
    }
}

extension NSObject {
    static func swizzle(_ original: Selector, _ replacement: Selector) {
        let originalMethodSet = class_getInstanceMethod(self as AnyClass, original)
        let swizzledMethodSet = class_getInstanceMethod(self as AnyClass, replacement)

        method_exchangeImplementations(originalMethodSet!, swizzledMethodSet!)
    }
}
