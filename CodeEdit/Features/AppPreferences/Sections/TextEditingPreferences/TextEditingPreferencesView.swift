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
    private var tabWidthFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 8

        return formatter
    }

    /// only allows float values in the range of `[0.75...2.00]`
    /// and formats to 2 decimal places.
    private var lineHeightFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.minimum = 0.75
        formatter.maximum = 2.0

        return formatter
    }

    private var fontSizeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 288

        return formatter
    }

    var body: some View {
        PreferencesContent {
            PreferencesSection("Default Tab Width") {
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
            PreferencesSection("Font") {
                fontSelector
            }
            PreferencesSection("Font Size") {
                fontSizeSelector
            }
            PreferencesSection("Line Height") {
                lineHeight
            }
            PreferencesSection("Code completion") {
                autocompleteBraces
                enableTypeOverCompletion
            }
            PreferencesSection("Line Wrapping") {
                wrapLinesToEditorWidth
            }
            PreferencesSection("Default Text Encoding") {
                textEncoding
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

    private var textEncoding: some View {
        Picker("Default Text Decoding", selection: $prefs.preferences.textEditing.textEncoding) {
            Group {
                Text("ASCII")
                    .tag(String.Encoding.ascii)
                Text("Non Lossy ASCII")
                    .tag(String.Encoding.nonLossyASCII)

                Divider()

                Text("ISO 2022 Japan")
                    .tag(String.Encoding.iso2022JP)
                Text("Japanese EUC")
                    .tag(String.Encoding.japaneseEUC)

                Divider()

                Text("ISO Latin 1")
                    .tag(String.Encoding.isoLatin1)
                Text("ISO Latin 2")
                    .tag(String.Encoding.isoLatin2)
                Text("macOS Roman")
                    .tag(String.Encoding.macOSRoman)
            }

            Group {
                Divider()

                Text("Nextstep")
                    .tag(String.Encoding.nextstep)
                Text("Shift JIS")
                    .tag(String.Encoding.shiftJIS)
                Text("Symbol")
                    .tag(String.Encoding.symbol)

                Divider()
            }

            Group {
                Text("Unicode")
                    .tag(String.Encoding.unicode)

                Text("Unicode (UTF-8)")
                    .tag(String.Encoding.utf8)

                Divider()

                Text("Unicode (UTF-16)")
                    .tag(String.Encoding.utf16)
                Text("Unicode (UTF-16) Big Endian")
                    .tag(String.Encoding.utf16be)
                Text("Unicode (UTF-16) Little Endian")
                    .tag(String.Encoding.utf16le)

                Divider()

                Text("Unicode (UTF-32)")
                    .tag(String.Encoding.utf32)
                Text("Unicode (UTF-32) Big Endian")
                    .tag(String.Encoding.utf32be)
                Text("Unicode (UTF-32) Little Endian")
                    .tag(String.Encoding.utf32le)
            }
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
}
