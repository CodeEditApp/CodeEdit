//
//  View+if.swift
//  CodeEdit
//
//  Created by Khan Winter on 8/28/25.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, @ViewBuilder transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
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

extension Bool {
     static var tahoe: Bool {
         if #available(macOS 26, *) {
             return true
         } else {
             return false
         }
     }
 }
