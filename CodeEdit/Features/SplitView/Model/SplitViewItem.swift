//
//  SplitViewItem.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI
import Combine

class SplitViewItem: ObservableObject {

    var id: AnyHashable
    var item: NSSplitViewItem

    var collapsed: Binding<Bool>

    var cancellables: [AnyCancellable] = []

    var observers: [NSKeyValueObservation] = []

    init(child: _VariadicView.Children.Element) {
        self.id = child.id
        self.item = NSSplitViewItem(viewController: NSHostingController(rootView: child))
        self.collapsed = child[SplitViewItemCollapsedViewTraitKey.self]
        self.item.canCollapse = child[SplitViewItemCanCollapseViewTraitKey.self]
        self.item.isCollapsed = self.collapsed.wrappedValue
        self.item.holdingPriority = child[SplitViewHoldingPriorityTraitKey.self]
        // Skip the initial observation via a dispatch to avoid a "updating during view update" error
        DispatchQueue.main.async {
            self.observers = self.createObservers()
        }
    }

    private func createObservers() -> [NSKeyValueObservation] {
        [
            item.observe(\.isCollapsed) { [weak self] item, _ in
                self?.collapsed.wrappedValue = item.isCollapsed
            }
        ]
    }

    /// Updates a SplitViewItem.
    /// This will fetch updated binding values and update them if needed.
    /// - Parameter child: the view corresponding to the SplitViewItem.
    func update(child: _VariadicView.Children.Element) {
        self.item.canCollapse = child[SplitViewItemCanCollapseViewTraitKey.self]
        DispatchQueue.main.async {
            self.observers = []
            self.item.animator().isCollapsed = child[SplitViewItemCollapsedViewTraitKey.self].wrappedValue
            self.item.holdingPriority = child[SplitViewHoldingPriorityTraitKey.self]
            self.observers = self.createObservers()
        }
    }
}
