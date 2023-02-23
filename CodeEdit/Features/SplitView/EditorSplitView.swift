//
//  EditorSplitView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/02/2023.
//

import SwiftUI

struct SplitViewItem: Hashable {
    var id: AnyHashable
    var item: NSSplitViewItem

    init(id: AnyHashable, controller: NSViewController) {
        self.id = id
        self.item = .init(viewController: controller)
        self.item.minimumThickness = 200
        self.item.canCollapse = false
    }
}

struct EditorSplitView: NSViewControllerRepresentable {

    var axis: Axis

    var children: _VariadicView.Children

    var splitPosition: CGFloat

    func makeNSViewController(context: Context) -> SplitViewController {
        let controller = SplitViewController(childrenn: children, axis: axis)

        return controller
    }

    func updateNSViewController(_ controller: SplitViewController, context: Context) {
        print("Update!")

        // Reorder viewcontrollers if needed and add new ones.
        var hasChanged = false
        controller.items = children.map { child in
            if let item = controller.items.first(where: { $0.id == child.id }) {
                return item
            } else {
                hasChanged = true
                return SplitViewItem(id: child.id, controller: NSHostingController(rootView: child))
            }
        }

        controller.splitViewItems = controller.items.map(\.item)

        if hasChanged && controller.splitViewItems.count > 1 {
            controller.splitView.setPosition(splitPosition, ofDividerAt: 0)
            controller.splitView.layoutSubtreeIfNeeded()
                    controller.splitView.adjustSubviews()
        }
    }
}

final class SplitViewController: NSSplitViewController {

    var items: [SplitViewItem] = []

    var axis: Axis

    var childrenn: _VariadicView.Children

    init(childrenn: _VariadicView.Children, axis: Axis = .horizontal) {
        self.childrenn = childrenn
        self.axis = axis
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        splitView.isVertical = axis != .vertical
        splitView.dividerStyle = .thick
    }

    override func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        false
    }
}
