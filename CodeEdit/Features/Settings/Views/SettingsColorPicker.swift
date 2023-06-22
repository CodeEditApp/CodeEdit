//
//  SettingsColorPicker.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/3/23.
//

import SwiftUI

struct SettingsColorPicker: View {

    /// Color modified elsewhere in user theme
    @Binding var color: Color

    /// Component private color to display
    /// UI changes
    @State private var selectedColor: Color

    private let label: String

    init(_ label: String, color: Binding<Color>) {
        self._color = color
        self.label = label
        self._selectedColor = State(initialValue: color.wrappedValue)
    }

    var body: some View {
        LabeledContent(label) {
            ColorPicker(selection: $selectedColor, supportsOpacity: false) { }
                .labelsHidden()
        }
        .onChange(of: selectedColor) { newValue in
            color = newValue
        }
    }
}
