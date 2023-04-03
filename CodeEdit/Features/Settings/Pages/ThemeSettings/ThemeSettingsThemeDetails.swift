//
//  ThemeSettingsThemeDetails.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/3/23.
//

import SwiftUI

struct ThemeSettingsThemeDetails: View {
    var theme: Theme
    var close: () -> Void

    @StateObject
    private var themeModel: ThemeModel = .shared

    @State private var displayName: String

    init(_ theme: Theme, close: @escaping () -> Void) {
        self.theme = theme
        self.close = close
        self.displayName = theme.displayName
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("Name", text: $displayName)
                }
                if let selectedTheme = themeModel.selectedTheme,
                   let index = themeModel.themes.firstIndex(of: selectedTheme) {
                    Section {
                        SettingsColorPicker(
                            "Text",
                            color: $themeModel.themes[index].editor.text.swiftColor
                        )
                        SettingsColorPicker(
                            "Cursor",
                            color: $themeModel.themes[index].editor.insertionPoint.swiftColor
                        )
                        SettingsColorPicker(
                            "Invisibles",
                            color: $themeModel.themes[index].editor.invisibles.swiftColor
                        )
                    }
                    Section {
                        SettingsColorPicker(
                            "Background",
                            color: $themeModel.themes[index].editor.background.swiftColor
                        )
                        SettingsColorPicker(
                            "Current Line",
                            color: $themeModel.themes[index].editor.lineHighlight.swiftColor
                        )
                        SettingsColorPicker(
                            "Selection",
                            color: $themeModel.themes[index].editor.selection.swiftColor
                        )
                    }
                    Section {
                        SettingsColorPicker(
                            "Keywords",
                            color: $themeModel.themes[index].editor.keywords.swiftColor
                        )
                        SettingsColorPicker(
                            "Commands",
                            color: $themeModel.themes[index].editor.commands.swiftColor
                        )
                        SettingsColorPicker(
                            "Types",
                            color: $themeModel.themes[index].editor.types.swiftColor
                        )
                        SettingsColorPicker(
                            "Attributes",
                            color: $themeModel.themes[index].editor.attributes.swiftColor
                        )
                        SettingsColorPicker(
                            "Variables",
                            color: $themeModel.themes[index].editor.variables.swiftColor
                        )
                        SettingsColorPicker(
                            "Values",
                            color: $themeModel.themes[index].editor.values.swiftColor
                        )
                        SettingsColorPicker(
                            "Numbers",
                            color: $themeModel.themes[index].editor.numbers.swiftColor
                        )
                        SettingsColorPicker(
                            "Strings",
                            color: $themeModel.themes[index].editor.strings.swiftColor
                        )
                        SettingsColorPicker(
                            "Characters",
                            color: $themeModel.themes[index].editor.characters.swiftColor
                        )
                        SettingsColorPicker(
                            "Comments",
                            color: $themeModel.themes[index].editor.comments.swiftColor
                        )
                    }
                }
            }.formStyle(.grouped)
            Divider()
            HStack {
                Spacer()
                Button {
                    close()
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
