//
//  Variadic.swift
//  CodeEditUI
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI

public struct Helper<Result: View>: _VariadicView_UnaryViewRoot {
    var _body: (_VariadicView.Children) -> Result

    public func body(children: _VariadicView.Children) -> some View {
        _body(children)
    }
}

public extension View {
    /// Exposes this view's resolved children so `process` can rebuild the hierarchy from them, e.g. to
    /// read per-child view traits. Used by ``SplitView`` to turn its content into individual split items.
    func variadic<R: View>(@ViewBuilder process: @escaping (_VariadicView.Children) -> R) -> some View {
        _VariadicView.Tree(Helper(_body: process), content: { self })
    }
}
