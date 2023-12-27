//
//  View+draggable.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import SwiftUI

private struct DraggableClosureViewModifier<T: Transferable>: ViewModifier {

    let payload: () -> T

    var helper: T {
        payload()
    }

    func body(content: Content) -> some View {
        content.draggable(helper)
    }
}

extension View {
    func draggable<T: Transferable>(_ payload: @escaping () -> T) -> some View {
        modifier(DraggableClosureViewModifier(payload: payload))
    }
}
