//
//  Environment+SplitEditor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

struct SplitEditorEnvironmentKey: EnvironmentKey {
    static var defaultValue: (Edge, TabGroupData) -> Void = { _, _ in }
}

extension EnvironmentValues {
    var splitEditor: SplitEditorEnvironmentKey.Value {
        get { self[SplitEditorEnvironmentKey.self] }
        set { self[SplitEditorEnvironmentKey.self] = newValue }
    }
}
