//
//  EditorThemeView.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// A view that implements the `Editor theme` preference section
struct EditorThemeView: View {

    // MARK: - View

    var body: some View {
        editorThemeViewSection
    }

    @StateObject
    private var themeModel: ThemeModel = .shared

    @StateObject
    private var prefs: SettingsModel = .shared
}

private extension EditorThemeView {

    // MARK: - Sections

    private var editorThemeViewSection: some View {
        ZStack(alignment: .topLeading) {
            EffectView(.contentBackground)
            if let selectedTheme = themeModel.selectedTheme,
               let index = themeModel.themes.firstIndex(of: selectedTheme) {
                VStack(alignment: .leading, spacing: 0) {
                    useThemeBackground
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.text.swiftColor,
                                label: "Text"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.insertionPoint.swiftColor,
                                label: "Cursor"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.invisibles.swiftColor,
                                label: "Invisibles"
                            )
                        }
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 10) {
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.background.swiftColor,
                                label: "Background"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.lineHighlight.swiftColor,
                                label: "Current Line"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.selection.swiftColor,
                                label: "Selection"
                            )
                        }
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .padding(.bottom, 20)

                    syntaxText
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.keywords.swiftColor,
                                label: "Keywords"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.commands.swiftColor,
                                label: "Commands"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.types.swiftColor,
                                label: "Types"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.attributes.swiftColor,
                                label: "Attributes"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.variables.swiftColor,
                                label: "Variables"
                            )
                        }
                            .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 10) {
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.values.swiftColor,
                                label: "Values"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.numbers.swiftColor,
                                label: "Numbers"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.strings.swiftColor,
                                label: "Strings"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.characters.swiftColor,
                                label: "Characters"
                            )
                            SettingsColorPicker(
                                $themeModel.themes[index].editor.comments.swiftColor,
                                label: "Comments"
                            )
                        }
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                        .padding(20)
                }
            } else {
                selectTheme
            }
        }
    }

    // MARK: - Preference Views

    private var useThemeBackground: some View {
        Toggle("Use theme background ", isOn: $prefs.settings.theme.useThemeBackground)
            .padding(.bottom, 20)
    }

    private var selectTheme: some View {
        Text("Select a Theme")
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var syntaxText: some View {
        Text("Syntax")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .padding(.bottom, 10)
    }
}
