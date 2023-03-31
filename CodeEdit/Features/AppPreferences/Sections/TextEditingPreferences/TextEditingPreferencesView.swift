//
//  TextEditingPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `Text Editing` preference section
struct TextEditingPreferencesView: View {
    // MARK: - View
    var body: some View {
        PreferencesContent {
            tabWidthSection
            fontSection
            lineHeightSection
            codeCompletionSection
            lineWrappingSection
        }
    }

    @StateObject
    private var prefs: AppPreferencesModel = .shared
}

private extension TextEditingPreferencesView {
    // MARK: - Sections
    private var tabWidthSection: some View {
        PreferencesSection("Default Tab Width") {
            defaultTabWidth
        }
    }

    private var fontSection: some View {
        PreferencesSection("Font") {
            fontSelector
            fontSizeSelector
        }
    }

    private var lineHeightSection: some View {
        PreferencesSection("Line Height") {
            lineHeight
        }
    }

    private var codeCompletionSection: some View {
        PreferencesSection("Code completion") {
            autocompleteBraces
            enableTypeOverCompletion
        }
    }

    private var lineWrappingSection: some View {
        PreferencesSection("Line Wrapping") {
            wrapLinesToEditorWidth
        }
    }

    // MARK: - Preference Views

    @ViewBuilder
    private var fontSelector: some View {
        HStack {
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
    }

    private var fontSizeSelector: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.preferences.textEditing.font.size, formatter: fontSizeFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Font Size:",
                value: $prefs.preferences.textEditing.font.size,
                in: 1...288,
                step: 1
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

    private var wrapLinesToEditorWidth: some View {
        HStack {
            Toggle("Wrap lines to editor width", isOn: $prefs.preferences.textEditing.wrapLinesToEditorWidth)
            Text("Wrap lines to editor width")
        }
    }

    private var lineHeight: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.preferences.textEditing.lineHeightMultiple, formatter: lineHeightFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Line Height:",
                value: $prefs.preferences.textEditing.lineHeightMultiple,
                in: 0.75...2.0,
                step: 0.05
            )
        }
    }

    private var defaultTabWidth: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.preferences.textEditing.defaultTabWidth, formatter: tabWidthFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Default Tab Width:",
                value: $prefs.preferences.textEditing.defaultTabWidth,
                in: 1...8
            )
            Text("spaces")
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
