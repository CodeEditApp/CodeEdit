//
//  Environment+SplitEditor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 16/02/2023.
//

import SwiftUI

public struct SplitEditorEnvironmentKey: EnvironmentKey {
    nonisolated(unsafe) public static var defaultValue: (Edge, Editor) -> Void = { _, _ in }
}

public extension EnvironmentValues {
    /// A closure that splits the current editor towards the given edge, inserting the provided editor.
    var splitEditor: SplitEditorEnvironmentKey.Value {
        get { self[SplitEditorEnvironmentKey.self] }
        set { self[SplitEditorEnvironmentKey.self] = newValue }
    }
}
