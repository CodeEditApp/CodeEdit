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
    @State private var isBold = false
    @State private var isItalic = false

    init(_ label: String, color: Binding<Color>) {
        self.label = label
        self._color = color
    }

    var body: some View {
        SettingsColorPicker(
            label,
            color: $color
        ) {
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
        }
        .padding(10)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
