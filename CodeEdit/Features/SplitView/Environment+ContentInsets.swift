//
//  Environment+ContentInsets.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 24/02/2023.
//

import SwiftUI

struct EdgeInsetsEnvironmentKey: EnvironmentKey {
    static var defaultValue: EdgeInsets = EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0)
}

extension EnvironmentValues {
    var edgeInsets: EdgeInsetsEnvironmentKey.Value {
        get { self[EdgeInsetsEnvironmentKey.self] }
        set { self[EdgeInsetsEnvironmentKey.self] = newValue }
    }
}

extension EdgeInsets {
    var nsEdgeInsets: NSEdgeInsets {
        .init(top: top, left: leading, bottom: bottom, right: trailing)
    }
}
