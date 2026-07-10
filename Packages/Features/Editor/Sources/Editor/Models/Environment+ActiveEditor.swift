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
    var isActiveEditor: Bool {
        get { self[ActiveEditorEnvironmentKey.self] }
        set { self[ActiveEditorEnvironmentKey.self] = newValue }
    }
}
