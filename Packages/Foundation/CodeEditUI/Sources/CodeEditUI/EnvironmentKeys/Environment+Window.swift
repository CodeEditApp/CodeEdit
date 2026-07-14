//
//  Environment+Window.swift
//  CodeEditUI
//
//  Created by Wouter Hennen on 14/01/2023.
//

import SwiftUI

/// Wraps a weak `NSWindow` reference so it can travel through the SwiftUI environment without the
/// environment retaining the window.
public struct WindowBox {
    /// The boxed window; nil once the window is gone or when none was injected.
    public weak var value: NSWindow?
    /// Creates a box holding a weak reference to the given window.
    public init(value: NSWindow? = nil) { self.value = value }
}

public struct NSWindowEnvironmentKey: EnvironmentKey {
    public typealias Value = WindowBox
    nonisolated(unsafe) public static var defaultValue = WindowBox(value: nil)
}

public extension EnvironmentValues {
    /// The `NSWindow` hosting this view hierarchy, boxed to avoid retaining it. Injected by the window
    /// controller at the SwiftUI root; the box is empty in previews.
    var window: WindowBox {
        get { self[NSWindowEnvironmentKey.self] }
        set { self[NSWindowEnvironmentKey.self] = newValue }
    }
}
