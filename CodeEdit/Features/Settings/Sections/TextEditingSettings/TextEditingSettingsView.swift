//
//  TextEditingSettingsView.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `Text Editing` preference section
struct TextEditingSettingsView: View {

    // MARK: - View

    var body: some View {
        SettingsContent {
            tabWidthSection
            fontSection
            lineHeightSection
            codeCompletionSection
            lineWrappingSection
        }
            .frame(width: 715)
    }

    @StateObject
    private var prefs: SettingsModel = .shared
}

private extension TextEditingSettingsView {

    // MARK: - Sections

    private var tabWidthSection: some View {
        SettingsSection("Default Tab Width") {
            defaultTabWidth
        }
    }

    private var fontSection: some View {
        SettingsSection("Font") {
            fontSelector
            fontSizeSelector
        }
    }

    private var lineHeightSection: some View {
        SettingsSection("Line Height") {
            lineHeight
        }
    }

    private var codeCompletionSection: some View {
        SettingsSection("Code completion") {
            autocompleteBraces
            enableTypeOverCompletion
        }
    }

    private var lineWrappingSection: some View {
        SettingsSection("Line Wrapping") {
            wrapLinesToEditorWidth
        }
    }

    // MARK: - Preference Views

    @ViewBuilder
    private var fontSelector: some View {
        HStack {
            Picker("Font:", selection: $prefs.settings.textEditing.font.customFont) {
                Text("System Font")
                    .tag(false)
                Text("Custom")
                    .tag(true)
            }
            .fixedSize()
            if prefs.settings.textEditing.font.customFont {
                FontPicker(
                    "\(prefs.settings.textEditing.font.name) \(prefs.settings.textEditing.font.size)",
                    name: $prefs.settings.textEditing.font.name, size: $prefs.settings.textEditing.font.size
                )
            }
        }
    }

    private var fontSizeSelector: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.settings.textEditing.font.size, formatter: fontSizeFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Font Size:",
                value: $prefs.settings.textEditing.font.size,
                in: 1...288,
                step: 1
            )
        }
    }

    private var autocompleteBraces: some View {
        HStack {
            Toggle("Autocomplete braces", isOn: $prefs.settings.textEditing.autocompleteBraces)
            Text("Automatically insert closing braces (\"}\")")
        }
    }

    private var enableTypeOverCompletion: some View {
        HStack {
            Toggle("Enable type-over completion", isOn: $prefs.settings.textEditing.enableTypeOverCompletion)
            Text("Enable type-over completion")
        }
    }

    private var wrapLinesToEditorWidth: some View {
        HStack {
            Toggle("Wrap lines to editor width", isOn: $prefs.settings.textEditing.wrapLinesToEditorWidth)
            Text("Wrap lines to editor width")
        }
    }

    private var lineHeight: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.settings.textEditing.lineHeightMultiple, formatter: lineHeightFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Line Height:",
                value: $prefs.settings.textEditing.lineHeightMultiple,
                in: 0.75...2.0,
                step: 0.05
            )
        }
    }

    private var defaultTabWidth: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.settings.textEditing.defaultTabWidth, formatter: tabWidthFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Default Tab Width:",
                value: $prefs.settings.textEditing.defaultTabWidth,
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
