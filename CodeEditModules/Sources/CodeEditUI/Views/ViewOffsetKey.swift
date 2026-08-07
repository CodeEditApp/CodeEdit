//
//  ViewOffsetKey.swift
//  CodeEditUI
//
//  Created by Austin Condiff on 4/8/23.
//

import SwiftUI

/// A `PreferenceKey` that accumulates a scalar view offset, used to track scroll position.
public struct ViewOffsetKey: PreferenceKey {
    public typealias Value = CGFloat
    public static let defaultValue = CGFloat.zero
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
