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
                textEncoding
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

    private var fontSizeSelector: some View {
        Stepper(
            "Font Size",
            value: $textEditing.font.size,
            in: 1...288,
            step: 1,
            format: .number
        )
    }

    private var autocompleteBraces: some View {
        Toggle(isOn: $textEditing.autocompleteBraces) {
            Text("Autocomplete braces")
            Text("Automatically insert closing braces (\"}\")")
        }
    }

    private var enableTypeOverCompletion: some View {
        Toggle("Enable type-over completion", isOn: $textEditing.enableTypeOverCompletion)
    }

    private var wrapLinesToEditorWidth: some View {
        Toggle("Wrap lines to editor width", isOn: $textEditing.wrapLinesToEditorWidth)
    }

    private var lineHeight: some View {
        Stepper(
            "Line Height",
            value: $textEditing.lineHeightMultiple,
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
                    get: { Double(textEditing.defaultTabWidth) },
                    set: { textEditing.defaultTabWidth = Int($0) }
                ),
                in: 1...8,
                step: 1,
                format: .number
            )
            Text("spaces")
                .foregroundColor(.secondary)
        }
    }

    private var textEncoding: some View {
        Picker("Default Text Encoding", selection: $textEditing.defaultTextEncoding) {
            ForEach(String.Encoding.allGroups, id: \.self) { group in
                ForEach(group, id: \.rawValue) { encoding in
                    Text(encoding.description)
                        .tag(encoding)
                }
            }
        }
    }
}
