//
//  DropdownMenuItemStyleModifier.swift
//  CodeEdit
//
//  Created by Tommy Ludwig on 24.06.24.
//

import SwiftUI

extension View {
    @ViewBuilder
    func dropdownItemStyle() -> some View {
        self.modifier(DropdownMenuItemStyleModifier())
    }
}

struct DropdownMenuItemStyleModifier: ViewModifier {
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                isHovering
                ? AnyView(EffectView(.selection, blendingMode: .withinWindow, emphasized: true))
                    : AnyView(Color.clear)
            )
            .foregroundColor(isHovering ? Color(NSColor.white) : .primary)
            .if(.tahoe) {
                if #available(macOS 26, *) {
                    $0.clipShape(ContainerRelativeShape())
                }
            } else: {
                $0.clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .onHover(perform: { hovering in
                self.isHovering = hovering
            })
    }
}
