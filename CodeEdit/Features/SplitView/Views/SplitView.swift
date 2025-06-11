//
//  SplitView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 22/02/2023.
//

import SwiftUI

struct SplitView<Content: View>: View {
    var axis: Axis
    var dividerStyle: CodeEditDividerStyle
    var content: Content

    init(axis: Axis, dividerStyle: CodeEditDividerStyle = .system(.thin), @ViewBuilder content: () -> Content) {
        self.axis = axis
        self.dividerStyle = dividerStyle
        self.content = content()
    }

    @State private var viewController: () -> SplitViewController? = { nil }

    var body: some View {
        VStack {
            content.variadic { children in
                SplitViewControllerView(
                    axis: axis,
                    dividerStyle: dividerStyle,
                    children: children,
                    viewController: $viewController
                )
            }
        }
        ._trait(SplitViewControllerLayoutValueKey.self, viewController)
        .accessibilityElement(children: .contain)
    }
}
