//
//  SplitViewItem.swift
//  CodeEditUI
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI
import Combine

@MainActor
public class SplitViewItem: ObservableObject {

    public var id: AnyHashable
    public var item: NSSplitViewItem

    var collapsed: Binding<Bool>

    var cancellables: [AnyCancellable] = []

    var observers: [NSKeyValueObservation] = []

    public init(child: _VariadicView.Children.Element) {
        self.id = child.id
        self.item = NSSplitViewItem(viewController: NSHostingController(rootView: child))
        self.collapsed = child[SplitViewItemCollapsedViewTraitKey.self]
        self.item.canCollapse = child[SplitViewItemCanCollapseViewTraitKey.self]
        self.item.isCollapsed = self.collapsed.wrappedValue
        self.item.holdingPriority = child[SplitViewHoldingPriorityTraitKey.self]
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

    public func update(child: _VariadicView.Children.Element) {
        self.item.canCollapse = child[SplitViewItemCanCollapseViewTraitKey.self]
        let canAnimate = child[SplitViewItemCanAnimateViewTraitKey.self]
        DispatchQueue.main.async {
            self.observers = []
            let collapsed = child[SplitViewItemCollapsedViewTraitKey.self].wrappedValue
            if canAnimate {
                self.item.animator().isCollapsed = collapsed
            } else {
                self.item.isCollapsed = collapsed
            }
            self.item.holdingPriority = child[SplitViewHoldingPriorityTraitKey.self]
            self.observers = self.createObservers()
        }
    }
}
