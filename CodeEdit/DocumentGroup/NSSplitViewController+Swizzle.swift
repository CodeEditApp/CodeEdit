//
//  NSSplitViewController+Swizzle.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 11/01/2023.
//

import SwiftUI

struct ControllableSplitView<Sidebar: View, Content: View, Detail: View>: NSViewControllerRepresentable {

    @ViewBuilder
    var sidebar: Sidebar

    @ViewBuilder
    var content: Content

    @ViewBuilder
    var detail: Detail

    func makeNSViewController(context: Context) -> some NSViewController {
        let splitVC = NSSplitViewController()

        let navigator = NSSplitViewItem(
            sidebarWithViewController: NSHostingController(rootView: sidebar)
        )
        navigator.titlebarSeparatorStyle = .none
        navigator.minimumThickness = 260
        navigator.collapseBehavior = .useConstraints
        splitVC.addSplitViewItem(navigator)

        let mainContent = NSSplitViewItem(
            viewController: NSHostingController(rootView: content)
        )
        mainContent.titlebarSeparatorStyle = .line
        splitVC.addSplitViewItem(mainContent)

        let inspector = NSSplitViewItem(
            viewController: NSHostingController(rootView: detail)
        )
        inspector.titlebarSeparatorStyle = .none
        inspector.minimumThickness = 260
        inspector.maximumThickness = 260
        inspector.isCollapsed = true
        inspector.collapseBehavior = .useConstraints
        splitVC.addSplitViewItem(inspector)

        return splitVC
    }

    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {

    }

    func makeCoordinator() {

    }

}
