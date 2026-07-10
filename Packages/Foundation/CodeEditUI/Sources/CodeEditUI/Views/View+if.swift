//
//  View+if.swift
//  CodeEditUI
//
//  Created by Khan Winter on 8/28/25.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

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
    static var tahoe: Bool {
        if #available(macOS 26, *) {
            return true
        } else {
            return false
        }
    }
}
