//
//  SplitViewControllerView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 20/02/2023.
//

import SwiftUI

struct SplitViewControllerView: NSViewControllerRepresentable {

    var axis: Axis
    var dividerStyle: CodeEditDividerStyle
    var children: _VariadicView.Children
    @Binding var viewController: () -> SplitViewController?

    func makeNSViewController(context: Context) -> SplitViewController {
        let controller = SplitViewController(axis: axis)
        updateItems(controller: controller)
        return controller
    }

    func updateNSViewController(_ controller: SplitViewController, context: Context) {
        updateItems(controller: controller)
        controller.setDividerStyle(dividerStyle)
    }

    private func updateItems(controller: SplitViewController) {
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
            let splitView = controller.splitView
            let numerator = splitView.isVertical ? splitView.frame.width : splitView.frame.height

            for idx in 0..<controller.items.count-1 {
                // If the next view is collapsed, don't reposition the divider.
                guard !controller.items[idx+1].item.isCollapsed else { continue }

                // This method needs to be run twice to ensure the split works correctly if split vertical.
                // I've absolutely no idea why but it works.
                splitView.setPosition(
                    CGFloat(idx + 1) * numerator/CGFloat(controller.items.count),
                    ofDividerAt: idx
                )
                splitView.setPosition(
                    CGFloat(idx + 1) * numerator/CGFloat(controller.items.count),
                    ofDividerAt: idx
                )
            }
        }
    }

    func makeCoordinator() -> SplitViewController {
        SplitViewController(axis: axis)
    }
}

final class SplitViewController: NSSplitViewController {
    final class CustomSplitView: NSSplitView {
        @Invalidating(.display)
        var customDividerStyle: CodeEditDividerStyle = .system(.thin) {
            didSet {
                switch customDividerStyle {
                case .system(let dividerStyle, _):
                    self.dividerStyle = dividerStyle
                case .thick:
                    return
                }
            }
        }

        init() {
            super.init(frame: .zero)
            dividerStyle = .thin
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override var dividerColor: NSColor {
            if let customColor = customDividerStyle.color {
                return customColor
            }
            
            switch customDividerStyle {
            case .system:
                return super.dividerColor
            case .thick:
                return NSColor.separatorColor
            }
        }

        override var dividerThickness: CGFloat {
            switch customDividerStyle {
            case .system:
                return super.dividerThickness
            case .thick:
                return 3.0
            }
        }
    }

    var items: [SplitViewItem] = []
    var axis: Axis
    var parentView: SplitViewControllerView?

    init(axis: Axis) {
        self.axis = axis
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        splitView = CustomSplitView()
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        splitView.isVertical = axis != .vertical
        DispatchQueue.main.async { [weak self] in
            self?.parentView?.viewController = { [weak self] in
                self
            }
        }
    }

    override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        false
    }

    func setDividerStyle(_ dividerStyle: CodeEditDividerStyle) {
        guard let splitView = splitView as? CustomSplitView else {
            return
        }
        splitView.customDividerStyle = dividerStyle
    }

    func collapse(for id: AnyHashable, enabled: Bool) {
        items.first { $0.id == id }?.item.animator().isCollapsed = enabled
    }
}
