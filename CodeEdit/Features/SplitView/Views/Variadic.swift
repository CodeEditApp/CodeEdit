//
//  Variadic.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 05/03/2023.
//

import SwiftUI

struct Helper<Result: View>: _VariadicView_UnaryViewRoot {
    var _body: (_VariadicView.Children) -> Result

    func body(children: _VariadicView.Children) -> some View {
        _body(children)
    }
}

extension View {

    /// Exposes the children of a ViewBuilder so they can be accessed individually.
    func variadic<R: View>(@ViewBuilder process: @escaping (_VariadicView.Children) -> R) -> some View {
        _VariadicView.Tree(Helper(_body: process), content: { self })
    }
}
