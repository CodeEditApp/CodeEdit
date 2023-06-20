//
//  View+focusedValue.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 18/06/2023.
//

import SwiftUI

extension View {
    func focusedValue<Value>(
        _ keyPath: WritableKeyPath<FocusedValues, Value?>,
        disabled: Bool,
        _ value: Value
    ) -> some View {
        focusedValue(keyPath, disabled ? nil : value)
    }
}
