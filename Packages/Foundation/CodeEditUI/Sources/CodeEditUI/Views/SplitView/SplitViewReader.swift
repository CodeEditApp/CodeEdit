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

public struct SplitViewProxy {
    private var viewController: () -> SplitViewController?

    public init(viewController: @escaping () -> SplitViewController?) {
        self.viewController = viewController
    }

    @MainActor
    public func setPosition(of index: Int, position: CGFloat) {
        viewController()?.splitView.setPosition(position, ofDividerAt: index)
    }

    @MainActor
    public func collapseView(with id: AnyHashable, _ enabled: Bool) {
        viewController()?.collapse(for: id, enabled: enabled)
    }
}
