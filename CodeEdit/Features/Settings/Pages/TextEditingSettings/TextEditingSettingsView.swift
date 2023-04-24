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
        MonospacedFontPicker(title: "Font", selectedFontName: $settings.textEditing.font.name)
            .onChange(of: settings.textEditing.font.name) { fontName in
                settings.textEditing.font.customFont = fontName != "SF Mono"
            }
    }

    private var fontSizeSelector: some View {
        Stepper(
            "Font Size",
            value: $settings.textEditing.font.size,
            in: 1...288,
            step: 1,
            format: .number
        )
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
        Stepper(
            "Line Height",
            value: $settings.textEditing.lineHeightMultiple,
            in: 0.75...2.0,
            step: 0.05,
            format: .number
        )
    }

    private var defaultTabWidth: some View {
        HStack(alignment: .top) {
            Stepper(
                "Default Tab Width",
                value: Binding<Double>(
                    get: { Double(settings.textEditing.defaultTabWidth) },
                    set: { settings.textEditing.defaultTabWidth = Int($0) }
                ),
                in: 1...8,
                step: 1,
                format: .number
            )
            Text("spaces")
                .foregroundColor(.secondary)
        }
    }
}
