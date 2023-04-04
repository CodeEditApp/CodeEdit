//
//  SettingsColorPicker.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/3/23.
//

import SwiftUI

/// A view that implements a `Color Picker`
struct SettingsColorPicker: View {
    @Binding
    var color: Color

    private let label: String

    init(_ label: String, color: Binding<Color>) {
        self._color = color
        self.label = label
    }

    var body: some View {
        LabeledContent(label) {
            ColorPicker(selection: $color, supportsOpacity: false) { }
                .labelsHidden()
        }
    }
}
