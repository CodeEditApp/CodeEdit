//
//  SplitViewModifiers.swift
//  CodeEditUI
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI

public struct SplitViewControllerLayoutValueKey: _ViewTraitKey {
    nonisolated(unsafe) public static var defaultValue: () -> SplitViewController? = { nil }
}

public struct SplitViewItemCollapsedViewTraitKey: _ViewTraitKey {
    nonisolated(unsafe) public static var defaultValue: Binding<Bool> = .constant(false)
}

public struct SplitViewItemCanCollapseViewTraitKey: _ViewTraitKey {
    nonisolated(unsafe) public static var defaultValue: Bool = false
}

public struct SplitViewHoldingPriorityTraitKey: _ViewTraitKey {
    nonisolated(unsafe) public static var defaultValue: NSLayoutConstraint.Priority = .defaultLow
}

public struct SplitViewItemCanAnimateViewTraitKey: _ViewTraitKey {
    public static var defaultValue: Bool { true }
}

public extension View {
    /// Binds the collapsed state of this split view item, so it can be collapsed and observed programmatically.
    func collapsed(_ value: Binding<Bool>) -> some View {
        self
            ._trait(SplitViewItemCollapsedViewTraitKey.self, .init {
                value.wrappedValue
            } set: {
                value.wrappedValue = $0
            })
    }

    /// Allows the user to collapse this split view item by dragging its divider to the edge.
    func collapsable() -> some View {
        self
            ._trait(SplitViewItemCanCollapseViewTraitKey.self, true)
    }

    /// Sets the holding priority of this split view item, deciding which item resizes first when space changes.
    func holdingPriority(_ priority: NSLayoutConstraint.Priority) -> some View {
        self
            ._trait(SplitViewHoldingPriorityTraitKey.self, priority)
    }

    /// Controls whether collapsing or expanding this split view item is animated.
    func splitViewCanAnimate(_ enabled: Binding<Bool>) -> some View {
        self._trait(SplitViewItemCanAnimateViewTraitKey.self, enabled.wrappedValue)
    }
}
