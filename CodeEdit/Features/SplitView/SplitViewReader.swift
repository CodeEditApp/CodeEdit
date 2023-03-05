//
//  SplitViewReader.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI

struct SplitViewReader<Content: View>: View {

    @ViewBuilder var content: (SplitViewProxy) -> Content

    @State private var viewController: SplitViewController?

    private var proxy: SplitViewProxy {
        .init {
            viewController
        }
    }

    var body: some View {
        content(proxy)
            .variadic { children in
                ForEach(children, id: \.id) { child in
                    child
                        .task {
                            if let vc = child[SplitViewControllerLayoutValueKey.self] {
                                viewController = vc
                            }
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

    func setPosition(of index: Int, position: CGFloat) {
        viewController()?.splitView.setPosition(position, ofDividerAt: index)
    }

    func collapseView(with id: AnyHashable, _ enabled: Bool) {
        viewController()?.collapse(for: id, enabled: enabled)
    }
}
