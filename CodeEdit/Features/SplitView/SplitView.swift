//
//  SequenceView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 22/02/2023.
//

import SwiftUI

// swiftlint:disable identifier_name
struct Helper<Result: View>: _VariadicView_MultiViewRoot {
    var _body: (_VariadicView.Children) -> Result

    func body(children: _VariadicView.Children) -> some View {
        _body(children)
    }
}

extension View {
    func variadic<R: View>(@ViewBuilder process: @escaping (_VariadicView.Children) -> R) -> some View {
        _VariadicView.Tree(Helper(_body: process), content: { self })
    }
}

struct SplitView<Content: View>: View {
    var axis: Axis

    @ViewBuilder var content: Content

    @State private var splitPosition = 1.0

    var body: some View {
        VStack {
            HStack {
                Stepper("Split position \(splitPosition)", value: $splitPosition, in: 0.0...500.0, step: 0.5)
                Slider(value: $splitPosition, in: 0.0...500.0)
                    .frame(width: 200)
            }
            content.variadic { children in
                EditorSplitView(axis: axis, children: children, splitPosition: splitPosition)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            }
        }
    }
}
