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
    @Binding var bold: Bool
    @Binding var italic: Bool

    @State private var selectedColor: Color
    @State private var isHovering = false

    init(_ label: String, color: Binding<Color>, bold: Binding<Bool>, italic: Binding<Bool>) {
        self.label = label
        self._color = color
        self._bold = bold
        self._italic = italic
        self._selectedColor = State(initialValue: color.wrappedValue)
    }

    var body: some View {
        LabeledContent {
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    Toggle(isOn: $bold) {
                        Image(systemName: "bold")
                    }
                    .toggleStyle(.icon)
                    .help("Bold")
                    Divider()
                        .fixedSize()
                    Toggle(isOn: $italic) {
                        Image(systemName: "italic")
                    }
                    .toggleStyle(.icon)
                    .help("Italic")
                }
                .opacity(isHovering || bold || italic ? 1 : 0)

                ColorPicker(selection: $selectedColor, supportsOpacity: false) { }
                    .labelsHidden()
            }
        } label: {
            Text(label)
                .font(.system(.body, design: .monospaced))
                .bold(bold)
                .italic(italic)
                .foregroundStyle(color)
        }
        .padding(10)
        .onHover { hovering in
            isHovering = hovering
        }
        .onChange(of: selectedColor) { _, newValue in
            color = newValue
        }
    }
}
