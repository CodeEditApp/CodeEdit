//
//  SequenceView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 22/02/2023.
//

import SwiftUI

struct SplitView<Content: View>: View {
    var content: Content

    @State
    var viewController: SplitViewController

    init(axis: Axis, @ViewBuilder content: () -> Content) {
        self.content = content()
        let vc = SplitViewController(axis: axis)
        self._viewController = .init(wrappedValue: vc)
    }

    var body: some View {
        VStack {
            content.variadic { children in
                SplitViewControllerView(children: children, viewController: viewController)
            }
        }
        ._trait(SplitViewControllerLayoutValueKey.self, viewController)
    }
}
