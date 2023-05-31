//
//  Scene+Environment.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 27/05/2023.
//

import SwiftUI

extension SwiftUI.Scene {
    @inlinable
    func modifier<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }

    @inlinable
    func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V) -> some Scene {
        modifier(_EnvironmentKeyWritingModifier(keyPath: keyPath, value: value))
    }
}
