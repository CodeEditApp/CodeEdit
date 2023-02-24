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
        item.minimumThickness = 200
        item.canCollapse = false
    }
}

struct EditorSplitView: NSViewControllerRepresentable {

    var axis: Axis
    var children: _VariadicView.Children

    func makeNSViewController(context: Context) -> SplitViewController {
        let controller = SplitViewController(axis: axis)
        return controller
    }

    func updateNSViewController(_ controller: SplitViewController, context: Context) {
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
            print(controller.items.count, controller.splitView.frame.width)
            print(controller.splitView.frame.width / CGFloat(controller.items.count))

            for idx in 0..<controller.items.count {
                controller.splitView.setPosition(
                    CGFloat(idx + 1) * controller.splitView.frame.width/CGFloat(controller.items.count),
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
        splitView.isVertical = axis != .vertical
        splitView.dividerStyle = .thin
    }

    override func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        false
    }
}
