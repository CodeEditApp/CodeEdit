//
//  Environment+ActiveEditor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 06/03/2023.
//

import SwiftUI

public struct ActiveEditorEnvironmentKey: EnvironmentKey {
    nonisolated(unsafe) public static var defaultValue = false
}

public extension EnvironmentValues {
    /// Whether the editor this view belongs to is the focused editor in the window.
    var isActiveEditor: Bool {
        get { self[ActiveEditorEnvironmentKey.self] }
        set { self[ActiveEditorEnvironmentKey.self] = newValue }
    }
}
