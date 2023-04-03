//
//  TextEditingSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/2/23.
//

import SwiftUI

/// A view that implements the `Text Editing` settings page
struct TextEditingSettingsView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        Form {
            Section {
                defaultTabWidth
                wrapLinesToEditorWidth
            }
            Section {
                fontSelector
                fontSizeSelector
                lineHeight
            }
            Section {
                autocompleteBraces
                enableTypeOverCompletion
            }
        }
        .formStyle(.grouped)
    }
}

private extension TextEditingSettingsView {
    // MARK: - Preference Views

    @ViewBuilder
    private var fontSelector: some View {
        Picker("Font", selection: $prefs.preferences.textEditing.font.customFont) {
            Text("System Font")
                .tag(false)
            Text("Custom")
                .tag(true)
        }
        if prefs.preferences.textEditing.font.customFont {
            FontPicker(
                "\(prefs.preferences.textEditing.font.name) \(prefs.preferences.textEditing.font.size)",
                name: $prefs.preferences.textEditing.font.name, size: $prefs.preferences.textEditing.font.size
            )
        }
    }

    private var fontSizeSelector: some View {
        TextField(
            "Font Size",
            value: $prefs.preferences.textEditing.font.size,
            formatter: fontSizeFormatter
        )
        .padding(.trailing, 15)
        .overlay(alignment: .trailing) {
            Stepper(
                "",
                value: $prefs.preferences.textEditing.font.size,
                in: 1...288,
                step: 1
            )
            .padding(.trailing, 8)
        }
    }

    private var autocompleteBraces: some View {
        Toggle(isOn: $prefs.preferences.textEditing.autocompleteBraces) {
            Text("Autocomplete braces")
            Text("Automatically insert closing braces (\"}\")")
        }
    }

    private var enableTypeOverCompletion: some View {
        Toggle("Enable type-over completion", isOn: $prefs.preferences.textEditing.enableTypeOverCompletion)
    }

    private var wrapLinesToEditorWidth: some View {
        Toggle("Wrap lines to editor width", isOn: $prefs.preferences.textEditing.wrapLinesToEditorWidth)
    }

    private var lineHeight: some View {
        TextField(
            "Line Height",
            value: $prefs.preferences.textEditing.lineHeightMultiple,
            formatter: lineHeightFormatter
        )
        .padding(.trailing, 15)
        .overlay(alignment: .trailing) {
            Stepper(
                "",
                value: $prefs.preferences.textEditing.lineHeightMultiple,
                in: 0.75...2.0,
                step: 0.05
            )
            .padding(.trailing, 8)
        }
    }

    private var defaultTabWidth: some View {
        LabeledContent("Default Tab Width") {
            TextField("", value: $prefs.preferences.textEditing.defaultTabWidth, formatter: tabWidthFormatter)
                .labelsHidden()
            Stepper("", value: $prefs.preferences.textEditing.defaultTabWidth, in: 1...8)
                .labelsHidden()
            Text("spaces")
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(.secondary)
                .textSelection(.disabled)
        }
    }

    // MARK: - Formatters

    /// Only allows integer values in the range of `[1...8]`
    private var tabWidthFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 8

        return formatter
    }

    /// Only allows float values in the range of `[0.75...2.00]`
    /// And formats to 2 decimal places.
    private var lineHeightFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.minimum = 0.75
        formatter.maximum = 2.0

        return formatter
    }

    /// Formatter for the font size in the range `[1...288]`
    /// Increases by 1
    private var fontSizeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 288

        return formatter
    }
}
