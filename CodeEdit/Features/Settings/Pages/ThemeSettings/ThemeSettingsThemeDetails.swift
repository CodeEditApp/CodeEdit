//
//  ThemeSettingsThemeDetails.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/3/23.
//

import SwiftUI

struct ThemeSettingsThemeDetails: View {
    @Environment(\.dismiss)
    var dismiss

    @Binding var theme: Theme

    @State private var initialTheme: Theme

    @StateObject private var themeModel: ThemeModel = .shared

    init(_ theme: Binding<Theme>) {
        _theme = theme
        _initialTheme = State(initialValue: theme.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("Name", text: $theme.displayName)
                }
                Section {
                    SettingsColorPicker(
                        "Text",
                        color: $theme.editor.text.swiftColor
                    )
                    SettingsColorPicker(
                        "Cursor",
                        color: $theme.editor.insertionPoint.swiftColor
                    )
                    SettingsColorPicker(
                        "Invisibles",
                        color: $theme.editor.invisibles.swiftColor
                    )
                }
                Section {
                    SettingsColorPicker(
                        "Background",
                        color: $theme.editor.background.swiftColor
                    )
                    SettingsColorPicker(
                        "Current Line",
                        color: $theme.editor.lineHighlight.swiftColor
                    )
                    SettingsColorPicker(
                        "Selection",
                        color: $theme.editor.selection.swiftColor
                    )
                }
                Section {
                    SettingsColorPicker(
                        "Keywords",
                        color: $theme.editor.keywords.swiftColor
                    )
                    SettingsColorPicker(
                        "Commands",
                        color: $theme.editor.commands.swiftColor
                    )
                    SettingsColorPicker(
                        "Types",
                        color: $theme.editor.types.swiftColor
                    )
                    SettingsColorPicker(
                        "Attributes",
                        color: $theme.editor.attributes.swiftColor
                    )
                    SettingsColorPicker(
                        "Variables",
                        color: $theme.editor.variables.swiftColor
                    )
                    SettingsColorPicker(
                        "Values",
                        color: $theme.editor.values.swiftColor
                    )
                    SettingsColorPicker(
                        "Numbers",
                        color: $theme.editor.numbers.swiftColor
                    )
                    SettingsColorPicker(
                        "Strings",
                        color: $theme.editor.strings.swiftColor
                    )
                    SettingsColorPicker(
                        "Characters",
                        color: $theme.editor.characters.swiftColor
                    )
                    SettingsColorPicker(
                        "Comments",
                        color: $theme.editor.comments.swiftColor
                    )
                }
            }.formStyle(.grouped)
            Divider()
            HStack {
                Spacer()
                Button {
                    theme = initialTheme
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .buttonStyle(.bordered)
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .constrainHeightToWindow()
    }
}
