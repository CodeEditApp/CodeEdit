//
//  SettingsColorPicker.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/3/23.
//

import SwiftUI

struct SettingsColorPicker<Content>: View where Content: View {

    /// Color modified elsewhere in user theme
    @Binding var color: Color

    /// Component private color to display
    /// UI changes
    @State private var selectedColor: Color

    private let label: String
    private let content: Content?

    init(_ label: String, color: Binding<Color>, @ViewBuilder content: @escaping () -> Content) {
        self._color = color
        self.label = label
        self._selectedColor = State(initialValue: color.wrappedValue)
        self.content = content()
    }

    init(_ label: String, color: Binding<Color>) where Content == EmptyView {
        self.init(label, color: color) {
            EmptyView()
        }
    }

    var body: some View {
        LabeledContent(label) {
            HStack(spacing: 16) {
                content
                ColorPicker(selection: $selectedColor, supportsOpacity: false) { }
                    .labelsHidden()
            }
        }
        .onChange(of: selectedColor) { _, newValue in
            color = newValue
        }
    }
}
