//
//  Environment+ModifierKeys.swift
//  CodeEditUI
//
//  Created by Wouter Hennen on 04/03/2023.
//

import SwiftUI

public struct EventModifierEnvironmentKey: EnvironmentKey {
    nonisolated(unsafe) public static var defaultValue: NSEvent.ModifierFlags = []
}

public extension EnvironmentValues {
    var modifierKeys: EventModifierEnvironmentKey.Value {
        get { self[EventModifierEnvironmentKey.self] }
        set { self[EventModifierEnvironmentKey.self] = newValue }
    }
}
