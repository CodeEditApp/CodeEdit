//
//  View+isHovering.swift
//  CodeEditModules/StatusBar
//
//  Created by Lukas Pistrol on 22.03.22.
//

import SwiftUI

extension View {

    /// Changes the cursor appearance when hovering attached View
    /// - Parameters:
    ///   - active: onHover() value
    ///   - isDragging: indicate that dragging is happening. If true this will not change the cursor.
    ///   - cursor: the cursor to display on hover
    func isHovering(_ active: Bool, isDragging: Bool = false, cursor: NSCursor = .arrow) {
        if isDragging { return }
        if active {
            cursor.push()
        } else {
            NSCursor.pop()
        }
    }
}
