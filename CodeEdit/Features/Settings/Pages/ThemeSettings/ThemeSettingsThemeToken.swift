//
//  ThemeSettingsThemeToken.swift
//  CodeEdit
//
//  Created by Austin Condiff on 5/14/24.
//

import SwiftUI

struct ThemeSettingsThemeToken: View {
    var label: String

    @Binding var color: Color

    @State private var selectedColor: Color

    init(_ label: String, color: Binding<Color>) {
        self.label = label
        self._color = color
        self._selectedColor = State(initialValue: color.wrappedValue)
    }

    var body: some View {
        LabeledContent {
            ColorPicker(selection: $selectedColor, supportsOpacity: false) { }
                .labelsHidden()
        } label: {
            Text(label)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(color)
        }
        .padding(10)
        .onChange(of: selectedColor) { newValue in
            color = newValue
        }
    }
}
