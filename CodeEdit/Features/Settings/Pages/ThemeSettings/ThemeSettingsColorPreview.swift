//
//  ThemeSettingsColorPreview.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/3/23.
//

import SwiftUI

struct ThemeSettingsColorPreview: View {
    var theme: Theme

    @StateObject private var themeModel: ThemeModel = .shared

    @State private var displayName: String

    init(_ theme: Theme) {
        self.theme = theme
        self.displayName = theme.displayName
    }

    var body: some View {
        HStack(spacing: 5) {
            ThemeSettingsColorPreviewColor(
                theme.editor.keywords.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.commands.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.types.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.attributes.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.variables.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.values.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.numbers.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.strings.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.characters.swiftColor
            )
            ThemeSettingsColorPreviewColor(
                theme.editor.comments.swiftColor
            )
        }
        .padding(12)
        .background(theme.editor.background.swiftColor)
        .clipShape(Capsule())
        .overlay {
            ZStack {
                Capsule()
                    .stroke(Color(.black).opacity(0.2), lineWidth: 0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                Capsule()
                    .strokeBorder(Color(.white).opacity(0.2), lineWidth: 0.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct ThemeSettingsColorPreviewColor: View {
    private var color: Color

    init(_ color: Color) {
        self.color = color
    }

    var body: some View {
        color
            .frame(width: 5, height: 5)
            .cornerRadius(5)
            .overlay {
                ZStack {
                    Circle()
                        .stroke(Color(.black).opacity(0.2), lineWidth: 0.5)
                        .frame(width: 5, height: 5)
                    Circle()
                        .strokeBorder(Color(.white).opacity(0.2), lineWidth: 0.5)
                        .frame(width: 5, height: 5)
                }
            }

    }
}
