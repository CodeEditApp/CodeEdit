//
//  Window.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 14/01/2023.
//

import SwiftUI

struct NSWindowEnvironmentKey: EnvironmentKey {
    static var defaultValue = NSWindow()
}

extension EnvironmentValues {
    var window: NSWindowEnvironmentKey.Value {
        get { self[NSWindowEnvironmentKey.self] }
        set { self[NSWindowEnvironmentKey.self] = newValue }
    }
}
