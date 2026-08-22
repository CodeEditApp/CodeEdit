//
//  SplitViewReader.swift
//  CodeEditUI
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI

public struct SplitViewReader<Content: View>: View {

    @ViewBuilder var content: (SplitViewProxy) -> Content

    public init(@ViewBuilder content: @escaping (SplitViewProxy) -> Content) {
        self.content = content
    }

    @State private var viewController: () -> SplitViewController? = { nil }

    private var proxy: SplitViewProxy {
        .init(viewController: viewController)
    }

    public var body: some View {
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

/// A handle to a `SplitView`, vended by ``SplitViewReader``, for imperatively moving dividers and
/// collapsing items.
public struct SplitViewProxy {
    private var viewController: () -> SplitViewController?

    /// Creates a proxy that resolves the underlying controller lazily, so it works before the split view exists.
    public init(viewController: @escaping () -> SplitViewController?) {
        self.viewController = viewController
    }

    /// Moves the divider at `index` to the given position, in points from the split view's leading/top edge.
    @MainActor
    public func setPosition(of index: Int, position: CGFloat) {
        viewController()?.splitView.setPosition(position, ofDividerAt: index)
    }

    /// Collapses or expands the split view item identified by `id`, animating the change.
    @MainActor
    public func collapseView(with id: AnyHashable, _ enabled: Bool) {
        viewController()?.collapse(for: id, enabled: enabled)
    }
}
