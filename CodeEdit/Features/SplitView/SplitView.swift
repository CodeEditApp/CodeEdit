//
//  SplitView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 22/02/2023.
//

import SwiftUI

struct SplitView<Content: View>: View {
    var axis: Axis
    var content: Content

    init(axis: Axis, @ViewBuilder content: () -> Content) {
        self.axis = axis
        self.content = content()
    }

    @State var viewController: () -> SplitViewController? = { nil }

    var body: some View {
        VStack {
            content.variadic { children in
                SplitViewControllerView(axis: axis, children: children, viewController: $viewController)
            }
        }
        ._trait(SplitViewControllerLayoutValueKey.self, viewController)
    }
}
