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
    func collapsed(_ value: Binding<Bool>) -> some View {
        self
            ._trait(SplitViewItemCollapsedViewTraitKey.self, .init {
                value.wrappedValue
            } set: {
                value.wrappedValue = $0
            })
    }

    func collapsable() -> some View {
        self
            ._trait(SplitViewItemCanCollapseViewTraitKey.self, true)
    }

    func holdingPriority(_ priority: NSLayoutConstraint.Priority) -> some View {
        self
            ._trait(SplitViewHoldingPriorityTraitKey.self, priority)
    }

    func splitViewCanAnimate(_ enabled: Binding<Bool>) -> some View {
        self._trait(SplitViewItemCanAnimateViewTraitKey.self, enabled.wrappedValue)
    }
}
