//
//  Environment+Window.swift
//  CodeEditUI
//
//  Created by Wouter Hennen on 14/01/2023.
//

import SwiftUI

public struct WindowBox {
    public weak var value: NSWindow?
    public init(value: NSWindow? = nil) { self.value = value }
}

public struct NSWindowEnvironmentKey: EnvironmentKey {
    public typealias Value = WindowBox
    nonisolated(unsafe) public static var defaultValue = WindowBox(value: nil)
}

public extension EnvironmentValues {
    var window: WindowBox {
        get { self[NSWindowEnvironmentKey.self] }
        set { self[NSWindowEnvironmentKey.self] = newValue }
    }
}
