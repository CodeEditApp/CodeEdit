//
//  TextEditingSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/2/23.
//

import SwiftUI

/// A view that implements the `Text Editing` settings page
struct TextEditingSettingsView: View {
    @AppSettings var settings

    var body: some View {
        SettingsForm {
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
    }
}

private extension TextEditingSettingsView {
    @ViewBuilder
    private var fontSelector: some View {
        Picker("Font", selection: $settings.textEditing.font.customFont) {
            Text("System Font")
                .tag(false)
            Text("Custom")
                .tag(true)
        }
        if settings.textEditing.font.customFont {
            FontPicker(
                "\(settings.textEditing.font.name) \(settings.textEditing.font.size)",
                name: $settings.textEditing.font.name, size: $settings.textEditing.font.size
            )
        }
    }

    private var fontSizeSelector: some View {
        LabeledContent("Font Size") {
            TextField("", value: $settings.textEditing.font.size, formatter: fontSizeFormatter)
                .labelsHidden()
            Stepper(
                "",
                value: $settings.textEditing.font.size,
                in: 1...288,
                step: 1
            )
            .labelsHidden()
        }
    }

    private var autocompleteBraces: some View {
        Toggle(isOn: $settings.textEditing.autocompleteBraces) {
            Text("Autocomplete braces")
            Text("Automatically insert closing braces (\"}\")")
        }
    }

    private var enableTypeOverCompletion: some View {
        Toggle("Enable type-over completion", isOn: $settings.textEditing.enableTypeOverCompletion)
    }

    private var wrapLinesToEditorWidth: some View {
        Toggle("Wrap lines to editor width", isOn: $settings.textEditing.wrapLinesToEditorWidth)
    }

    private var lineHeight: some View {
        LabeledContent("Line Height") {
            TextField(
                "",
                value: $settings.textEditing.lineHeightMultiple,
                formatter: lineHeightFormatter
            )
            .labelsHidden()
            Stepper(
                "",
                value: $settings.textEditing.lineHeightMultiple,
                in: 0.75...2.0,
                step: 0.05
            )
            .labelsHidden()
        }
    }

    private var defaultTabWidth: some View {
        LabeledContent("Default Tab Width") {
            TextField("", value: $settings.textEditing.defaultTabWidth, formatter: tabWidthFormatter)
                .labelsHidden()
            Stepper("", value: $settings.textEditing.defaultTabWidth, in: 1...8)
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
