//
//  Environment+ActiveEditor.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 06/03/2023.
//

import SwiftUI

struct ActiveEditorEnvironmentKey: EnvironmentKey {
    static var defaultValue = false
}

extension EnvironmentValues {
    var isActiveEditor: Bool {
        get { self[ActiveEditorEnvironmentKey.self] }
        set { self[ActiveEditorEnvironmentKey.self] = newValue }
    }
}
