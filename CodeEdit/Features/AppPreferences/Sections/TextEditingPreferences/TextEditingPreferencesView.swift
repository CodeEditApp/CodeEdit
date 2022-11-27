//
//  TextEditingPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `Text Editing` preference section
struct TextEditingPreferencesView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// only allows integer values in the range of `[1...8]`
    private var numberFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 8

        return formatter
    }

    var body: some View {
        PreferencesContent {
            PreferencesSection("Default Tab Width") {
                HStack(spacing: 5) {
                    TextField("", value: $prefs.preferences.textEditing.defaultTabWidth, formatter: numberFormat)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 40)
                    Stepper("Default Tab Width:",
                            value: $prefs.preferences.textEditing.defaultTabWidth,
                            in: 1...8)
                    Text("spaces")
                }
            }
            PreferencesSection("Font") {
                fontSelector
            }
            PreferencesSection("Code completion") {
                autocompleteBraces
                enableTypeOverCompletion
            }
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        Picker("Font:", selection: $prefs.preferences.textEditing.font.customFont) {
            Text("System Font")
                .tag(false)
            Text("Custom")
                .tag(true)
        }
        .fixedSize()
        if prefs.preferences.textEditing.font.customFont {
            FontPicker(
                "\(prefs.preferences.textEditing.font.name) \(prefs.preferences.textEditing.font.size)",
                name: $prefs.preferences.textEditing.font.name, size: $prefs.preferences.textEditing.font.size
            )
        }
    }

    private var autocompleteBraces: some View {
        HStack {
            Toggle("Autocomplete braces", isOn: $prefs.preferences.textEditing.autocompleteBraces)
            Text("Automatically insert closing braces (\"}\")")
        }
    }

    private var enableTypeOverCompletion: some View {
        HStack {
            Toggle("Enable type-over completion", isOn: $prefs.preferences.textEditing.enableTypeOverCompletion)
            Text("Enable type-over completion")
        }
    }
}
