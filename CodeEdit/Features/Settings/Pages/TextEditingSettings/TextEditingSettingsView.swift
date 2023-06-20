//
//  TextEditingSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 4/2/23.
//

import SwiftUI

/// A view that implements the `Text Editing` settings page
struct TextEditingSettingsView: View {
    @AppSettings(\.textEditing) var textEditing

    var body: some View {
        SettingsForm {
            Section {
                indentOption
                defaultTabWidth
                wrapLinesToEditorWidth
            }
            Section {
                fontSelector
                fontSizeSelector
                lineHeight
                letterSpacing
            }
            Section {
                autocompleteBraces
                enableTypeOverCompletion
            }
            Section {
                bracketPairHighlight
            }
        }
    }
}

private extension TextEditingSettingsView {
    @ViewBuilder
    private var fontSelector: some View {
        MonospacedFontPicker(title: "Font", selectedFontName: $textEditing.font.name)
            .onChange(of: textEditing.font.name) { fontName in
                textEditing.font.customFont = fontName != "SF Mono"
            }
    }

    @ViewBuilder
    private var fontSizeSelector: some View {
        Stepper(
            "Font Size",
            value: $textEditing.font.size,
            in: 1...288,
            step: 1,
            format: .number
        )
    }

    @ViewBuilder
    private var autocompleteBraces: some View {
        Toggle(isOn: $textEditing.autocompleteBraces) {
            Text("Autocomplete braces")
            Text("Automatically insert closing braces (\"}\")")
        }
    }

    @ViewBuilder
    private var enableTypeOverCompletion: some View {
        Toggle("Enable type-over completion", isOn: $textEditing.enableTypeOverCompletion)
    }

    @ViewBuilder
    private var wrapLinesToEditorWidth: some View {
        Toggle("Wrap lines to editor width", isOn: $textEditing.wrapLinesToEditorWidth)
    }

    @ViewBuilder
    private var lineHeight: some View {
        Stepper(
            "Line Height",
            value: $textEditing.lineHeightMultiple,
            in: 0.75...2.0,
            step: 0.05,
            format: .number
        )
    }

    @ViewBuilder
    private var indentOption: some View {
        IndentOptionView(indentOption: $textEditing.indentOption)
    }

    @ViewBuilder
    private var defaultTabWidth: some View {
        TabWidthOptionView(defaultTabWidth: $textEditing.defaultTabWidth)
    }

    @ViewBuilder
    private var letterSpacing: some View {
        Stepper(
            "Letter Spacing",
            value: $textEditing.letterSpacing,
            in: 0.5...2.0,
            step: 0.05,
            format: .number
        )
    }

    @ViewBuilder
    private var bracketPairHighlight: some View {
        Group {
            Picker(
                "Braket Pair Highlight",
                selection: $textEditing.bracketHighlight.highlightType
            ) {
                Text("Disabled").tag(SettingsData.TextEditingSettings.BracketPairHighlight.HighlightType.disabled)
                Divider()
                Text("Bordered").tag(SettingsData.TextEditingSettings.BracketPairHighlight.HighlightType.bordered)
                Text("Flash").tag(SettingsData.TextEditingSettings.BracketPairHighlight.HighlightType.flash)
                Text("Underline").tag(SettingsData.TextEditingSettings.BracketPairHighlight.HighlightType.underline)
            }
            if [.bordered, .underline].contains(textEditing.bracketHighlight.highlightType) {
                Toggle("Use Custom Color", isOn: $textEditing.bracketHighlight.useCustomColor)
                SettingsColorPicker(
                    "Braket Pair Highlight Color",
                    color: $textEditing.bracketHighlight.color.swiftColor
                )
                .foregroundColor(
                    textEditing.bracketHighlight.useCustomColor
                        ? Color(NSColor.labelColor)
                        : Color(NSColor.secondaryLabelColor)
                )
                .disabled(!textEditing.bracketHighlight.useCustomColor)
            }
        }
    }
}
