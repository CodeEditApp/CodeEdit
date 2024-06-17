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

    @State private var isHovering = false
    @State private var selectedColor: Color
    @State private var isBold = false
    @State private var isItalic = false

    init(_ label: String, color: Binding<Color>) {
        self.label = label
        self._color = color
        self._selectedColor = State(initialValue: color.wrappedValue)
    }

    var body: some View {
        LabeledContent {
            HStack(spacing: 16) {
                HStack(spacing: 8) {
                    Toggle(isOn: $isBold) {
                        Image(systemName: "bold")
                    }
                    .toggleStyle(.icon)
                    .help("Bold")
                    Divider()
                        .fixedSize()
                    Toggle(isOn: $isItalic) {
                        Image(systemName: "italic")
                    }
                    .toggleStyle(.icon)
                    .help("Italic")
                }
                .opacity(isHovering || isBold || isItalic ? 1 : 0)
                ColorPicker(selection: $selectedColor, supportsOpacity: false) { }
                    .labelsHidden()
            }
        } label: {
            Text(label)
                .font(.system(.body, design: .monospaced, weight: isBold ? .bold : .medium))
                .foregroundStyle(color)
                .italic(isItalic)
        }
        .padding(10)
        .onHover { hovering in
            isHovering = hovering
        }
        .onChange(of: selectedColor) { newValue in
            color = newValue
        }
    }
}
