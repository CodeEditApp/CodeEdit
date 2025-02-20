//
//  DropdownMenuItemStyleModifier.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

struct DropdownMenuItemStyleModifier: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .background(
                isHovering
                ? AnyView(EffectView(.selection, blendingMode: .withinWindow, emphasized: true))
                    : AnyView(Color.clear)
            )
            .foregroundColor(isHovering ? Color(NSColor.white) : .primary)
            .onHover(perform: { hovering in
                self.isHovering = hovering
            })
    }
}
