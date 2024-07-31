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
            .background(isHovering ? AnyView(HighlightedBackground()) : AnyView(Color.clear))
            .foregroundColor(isHovering ? Color(NSColor.white) : .primary)
            .onHover(perform: { hovering in
                self.isHovering = hovering
            })
    }
}
struct SelectionVisualEffectView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .selection
        view.blendingMode = .withinWindow
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct HighlightedBackground: View {
    var body: some View {
        SelectionVisualEffectView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
