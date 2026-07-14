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
    /// The modifier keys (command, option, shift, ...) currently held down, for views that adapt while
    /// a modifier is pressed.
    var modifierKeys: EventModifierEnvironmentKey.Value {
        get { self[EventModifierEnvironmentKey.self] }
        set { self[EventModifierEnvironmentKey.self] = newValue }
    }
}
