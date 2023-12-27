//
//  BasicTabView+Internal.swift
//  CodeEdit
//
//  Created by Wouter on 27/12/23.
//

import SwiftUI
import Engine

extension BasicTabView {
    struct InternalBasicTabView: NSViewControllerRepresentable {

        let children: AnyVariadicView
        let selected: Int?

        func makeNSViewController(context: Context) -> NSTabViewController {
            let controller = NSTabViewController()
            controller.tabStyle = .unspecified
            return controller
        }

        func updateNSViewController(_ nsViewController: NSTabViewController, context: Context) {
            var newDict: [AnyHashable: NSTabViewItem] = [:]
            var childViews: [NSTabViewItem] = []

            for child in children {
                let oldChild = context.coordinator.children[child.id]
                let newChild = oldChild ?? NSTabViewItem(viewController: NSHostingController(rootView: child))
                newDict[child.id] = newChild
                childViews.append(newChild)
            }

            context.coordinator.children = newDict
            DispatchQueue.main.async {
                nsViewController.tabViewItems = childViews
                nsViewController.selectedTabViewItemIndex = min(selected ?? 0, children.count-1)
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        class Coordinator {
            var children: [AnyHashable: NSTabViewItem] = [:]
        }
    }
}
