//
//  ThemeSettingThemeRow.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/3/23.
//

import SwiftUI

struct ThemeSettingsThemeRow: View {
    @Binding var theme: Theme
    var active: Bool
    var action: (Theme) -> Void

    @State private var presentingDetails: Bool = false

    @State private var isHovering = false

    var body: some View {
        HStack {
            Image(systemName: "checkmark")
                .opacity(active ? 1 : 0)
                .font(.system(size: 10.5, weight: .bold))
            VStack(alignment: .leading) {
                Text(theme.displayName)
                Text(theme.author)
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                presentingDetails = true
            } label: {
                Text("Details...")
            }
            .buttonStyle(.bordered)
            .opacity(isHovering ? 1 : 0)
            ThemeSettingsColorPreview(theme)
        }
        .padding(10)
        .onHover { hovering in
            isHovering = hovering
        }
        .onTapGesture {
            action(theme)
        }
        .sheet(isPresented: $presentingDetails) {
            ThemeSettingsThemeDetails($theme)
        }
    }
}
