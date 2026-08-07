//
//  View+if.swift
//  CodeEditUI
//
//  Created by Khan Winter on 8/28/25.
//

import SwiftUI

public extension View {
    /// Applies `transform` to the view only when `condition` is true, returning the view unchanged otherwise.
    /// Note the condition changing swaps the view's identity, resetting any state inside.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies `transform` to the view when `condition` is true, otherwise applies `elseTransform`.
    /// Note the condition changing swaps the view's identity, resetting any state inside.
    @ViewBuilder
    func `if`<Content: View, ElseContent: View>(
        _ condition: Bool,
        @ViewBuilder transform: (Self) -> Content,
        @ViewBuilder else elseTransform: (Self) -> ElseContent
    ) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
}

public extension Bool {
    /// Whether the app is running on macOS 26 (Tahoe) or later, for gating Tahoe-specific styling.
    static var tahoe: Bool {
        if #available(macOS 26, *) {
            return true
        } else {
            return false
        }
    }
}
