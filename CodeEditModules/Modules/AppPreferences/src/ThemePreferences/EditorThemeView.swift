//
//  EditorThemeView.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

struct EditorThemeView: View {

    @StateObject
    private var themeModel: ThemeModel = .shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color(NSColor.controlBackgroundColor))
            if let selectedTheme = themeModel.selectedTheme,
               let index = themeModel.themes.firstIndex(of: selectedTheme) {
                VStack(alignment: .leading, spacing: 0) {
                    Toggle("Use theme background ", isOn: .constant(true))
                        .padding(.bottom, 20)
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            PreferencesColorPicker($themeModel.themes[index].text.swiftColor,
                                                   label: "Text")
                            PreferencesColorPicker($themeModel.themes[index].insertionPoint.swiftColor,
                                                   label: "Cursor")
                            PreferencesColorPicker($themeModel.themes[index].invisibles.swiftColor,
                                                   label: "Invisibles")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading, spacing: 10) {
                            PreferencesColorPicker($themeModel.themes[index].background.swiftColor,
                                                   label: "Background")
                            PreferencesColorPicker($themeModel.themes[index].lineHighlight.swiftColor,
                                                   label: "Current Line")
                            PreferencesColorPicker($themeModel.themes[index].selection.swiftColor,
                                                   label: "Selection")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.bottom, 20)
                    Text("Syntax")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 10) {
                            PreferencesColorPicker($themeModel.themes[index].keywords.swiftColor,
                                                   label: "Keywords")
                            PreferencesColorPicker($themeModel.themes[index].commands.swiftColor,
                                                   label: "Commands")
                            PreferencesColorPicker($themeModel.themes[index].types.swiftColor,
                                                   label: "Types")
                            PreferencesColorPicker($themeModel.themes[index].attributes.swiftColor,
                                                   label: "Attributes")
                            PreferencesColorPicker($themeModel.themes[index].variables.swiftColor,
                                                   label: "Variables")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        VStack(alignment: .leading, spacing: 10) {
                            PreferencesColorPicker($themeModel.themes[index].values.swiftColor,
                                                   label: "Values")
                            PreferencesColorPicker($themeModel.themes[index].numbers.swiftColor,
                                                   label: "Numbers")
                            PreferencesColorPicker($themeModel.themes[index].strings.swiftColor,
                                                   label: "Strings")
                            PreferencesColorPicker($themeModel.themes[index].characters.swiftColor,
                                                   label: "Characters")
                            PreferencesColorPicker($themeModel.themes[index].comments.swiftColor,
                                                   label: "Comments")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
            }
        }
    }
}

struct EditorThemeView_Previews: PreviewProvider {
    static var previews: some View {
        EditorThemeView()
    }
}
