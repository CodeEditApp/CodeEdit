//
//  NSWindow+Child.swift
//  CodeEdit
//
//  Created by Axel Martinez on 8/4/24.
//

import AppKit

extension NSWindow {
    func addCenteredChildWindow(_ childWindow: NSWindow, over parentWindow: NSWindow) {
        let parentFrame = parentWindow.frame
        let parentCenterX = parentFrame.origin.x + (parentFrame.size.width / 2)
        let parentCenterY = parentFrame.origin.y + (parentFrame.size.height / 2)

        let childWidth = childWindow.frame.size.width
        let childHeight = childWindow.frame.size.height
        let newChildOriginX = parentCenterX - (childWidth / 2)
        let newChildOriginY = parentCenterY - (childHeight / 2)

        childWindow.setFrameOrigin(NSPoint(x: newChildOriginX, y: newChildOriginY))

        parentWindow.addChildWindow(childWindow, ordered: .above)
    }
}
