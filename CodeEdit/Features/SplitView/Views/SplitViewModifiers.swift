//
//  SplitViewModifiers.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI

struct SplitViewControllerLayoutValueKey: _ViewTraitKey {
    static var defaultValue: () -> SplitViewController? = { nil }
}

struct SplitViewItemCollapsedViewTraitKey: _ViewTraitKey {
    static var defaultValue: Binding<Bool> = .constant(false)
}

struct SplitViewItemCanCollapseViewTraitKey: _ViewTraitKey {
    static var defaultValue: Bool = false
}

struct SplitViewHoldingPriorityTraitKey: _ViewTraitKey {
    static var defaultValue: NSLayoutConstraint.Priority = .defaultLow
}

extension View {
    func collapsed(_ value: Binding<Bool>) -> some View {
        self
        // Use get/set instead of binding directly, so a view update will be triggered if the binding changes.
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
}
