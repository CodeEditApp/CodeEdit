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
    var showDividers: Bool = false

    init(axis: Axis, showDividers: Bool = false, @ViewBuilder content: () -> Content) {
        self.axis = axis
        self.showDividers = showDividers
        self.content = content()
    }

    @State var viewController: () -> SplitViewController? = { nil }

    var body: some View {
        VStack {
            content.variadic { children in
                SplitViewControllerView(axis: axis, children: children, showDividers: showDividers, viewController: $viewController)
            }
        }
        ._trait(SplitViewControllerLayoutValueKey.self, viewController)
    }
}
