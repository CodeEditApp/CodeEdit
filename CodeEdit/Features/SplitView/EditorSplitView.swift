//
//  EditorSplitView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/02/2023.
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
        self.observers = createObservers()
    }

    func createObservers() -> [NSKeyValueObservation] {
        [
            item.observe(\.isCollapsed) { item, _ in
                self.collapsed.wrappedValue = item.isCollapsed
            }
        ]
    }

    func update(child: _VariadicView.Children.Element) {
        self.item.canCollapse = child[SplitViewItemCanCollapseViewTraitKey.self]
        DispatchQueue.main.async {
            self.observers = []
            self.item.animator().isCollapsed = child[SplitViewItemCollapsedViewTraitKey.self].wrappedValue
            self.observers = self.createObservers()
        }
    }
}

struct EditorSplitView: NSViewControllerRepresentable {

    var children: _VariadicView.Children
    var viewController: SplitViewController

    func makeNSViewController(context: Context) -> SplitViewController {
//        viewController.items = children.map { SplitViewItem(child: $0) }
        return viewController
    }

    func updateNSViewController(_ controller: SplitViewController, context: Context) {
        updateItems(controller: controller)
    }

    func updateItems(controller: SplitViewController) {
        var hasChanged = false
        // Reorder viewcontrollers if needed and add new ones.
        controller.items = children.map { child in
            let item: SplitViewItem
            if let foundItem = controller.items.first(where: { $0.id == child.id }) {
                item = foundItem
                item.update(child: child)
            } else {
                hasChanged = true
                item = SplitViewItem(child: child)
            }
            return item
        }

        controller.splitViewItems = controller.items.map(\.item)
        if hasChanged && controller.splitViewItems.count > 1 {
            let numerator = controller.splitView.isVertical ? controller.splitView.frame.width : controller.splitView.frame.height
            for idx in 0..<controller.items.count-1 {
                // If the next view is collapsed, don't reposition the divider.
                guard !controller.items[idx+1].item.isCollapsed else { continue }
                controller.splitView.setPosition(
                    CGFloat(idx + 1) * numerator/CGFloat(controller.items.count),
                    ofDividerAt: idx
                )
                controller.splitView.setPosition(
                    CGFloat(idx + 1) * numerator/CGFloat(controller.items.count),
                    ofDividerAt: idx
                )
            }
        }
    }
}

final class SplitViewController: NSSplitViewController {

    var items: [SplitViewItem] = []
    var axis: Axis

    init(axis: Axis = .horizontal) {
        self.axis = axis
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
//        splitView.arrangesAllSubviews = false
        splitView.isVertical = axis != .vertical
        splitView.dividerStyle = .thin
    }

    override func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        false
    }

    func collapse(for id: AnyHashable, enabled: Bool) {
        items.first { $0.id == id }?.item.animator().isCollapsed = enabled
    }

//    override func splitViewDidResizeSubviews(_ notification: Notification) {
//        print(notification)
//    }
}
