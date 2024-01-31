//
//  DropdopMenuItem.swift
//  CodeEdit
//
//  Created by Axel Martinez on 15/2/24.
//

import SwiftUI

/// A view that represents a custom dropdown menu item
struct DropdownMenuItem: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .background(isHovering ? Color(NSColor.systemBlue) : .clear)
            .foregroundColor(isHovering ? Color(NSColor.white) : .primary)
            .onHover(perform: { hovering in
                self.isHovering = hovering
            })
    }
}

extension View {
    func dropdownMenuItem() -> some View {
        modifier(DropdownMenuItem())
    }
}
