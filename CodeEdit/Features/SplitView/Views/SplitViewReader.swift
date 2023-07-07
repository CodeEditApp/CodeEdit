//
//  SplitViewReader.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI

struct SplitViewReader<Content: View>: View {

    @ViewBuilder var content: (SplitViewProxy) -> Content

    @State private var viewController: () -> SplitViewController? = { nil }

    private var proxy: SplitViewProxy {
        .init(viewController: viewController)
    }

    var body: some View {
        content(proxy)
            .variadic { children in
                ForEach(children, id: \.id) { child in
                    child
                        .task(id: child[SplitViewControllerLayoutValueKey.self]()) {
                            viewController = child[SplitViewControllerLayoutValueKey.self]
                        }
                }
            }
    }
}

struct SplitViewProxy {
    private var viewController: () -> SplitViewController?

    fileprivate init(viewController: @escaping () -> SplitViewController?) {
        self.viewController = viewController
    }

    /// Set the position of a divider in a splitview.
    /// - Parameters:
    ///   - index: index of the divider. The mostleft / top divider has index 0.
    ///   - position: position to place the divider. This is a position inside the views width / height.
    ///   For example, if the splitview has a width of 500, setting the position to 250
    ///    will put the divider in the middle of the splitview.
    func setPosition(of index: Int, position: CGFloat) {
        viewController()?.splitView.setPosition(position, ofDividerAt: index)
    }

    /// Collapse a view of the splitview.
    /// - Parameters:
    ///   - id: ID of the view
    ///   - enabled: true for collapse.
    func collapseView(with id: AnyHashable, _ enabled: Bool) {
        viewController()?.collapse(for: id, enabled: enabled)
    }
}
