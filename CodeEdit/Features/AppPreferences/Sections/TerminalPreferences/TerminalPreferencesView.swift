//
//  TerminalPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 02.04.22.
//

import SwiftUI
import Preferences

/// A view that implements the `Terminal` preference section
struct TerminalPreferencesView: View {
    private let inputWidth: Double = 150

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    init() {}

    var body: some View {
        PreferencesContent {
            PreferencesSection("Shell") {
                shellSelector
                optionAsMetaToggle
            }
            PreferencesSection("Font") {
                fontSelector
            }
            PreferencesSection("Terminal window") {
                mouseReporting
                scrollBack
            }
            PreferencesSection("Cursor") {
                cursorStyle
                cursorBlink
            }
        }
    }

    /// Only allows integer values in the range of `[100...1,000,000]`
    private var scrollBackFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 100
        formatter.maximum = 1000000

        return formatter
    }

    private var scrollBack: some View {
        HStack(spacing: 5) {
            TextField("", value: $prefs.preferences.terminal.scrollBack, formatter: scrollBackFormatter)
                .multilineTextAlignment(.trailing)
                .frame(width: 40)
            Stepper(
                "Scroll back",
                value: $prefs.preferences.terminal.scrollBack,
                in: 100...1000000
            )
            Text("spaces")
        }
    }

    private var mouseReporting: some View {
        HStack {
            Toggle("Mouse reporting", isOn: $prefs.preferences.terminal.allowMouseReporting)
            Text("Allow mouse reporting")
        }
    }

    private var shellSelector: some View {
        Picker("Shell:", selection: $prefs.preferences.terminal.shell) {
            Text("System Default")
                .tag(AppPreferences.TerminalShell.system)
            Divider()
            Text("ZSH")
                .tag(AppPreferences.TerminalShell.zsh)
            Text("Bash")
                .tag(AppPreferences.TerminalShell.bash)
        }
        .frame(width: inputWidth)
    }
    private var cursorStyle: some View {
        Picker("Terminal Cursor Style: ", selection: $prefs.preferences.terminal.cursorStyle) {
            Text("Block")
                .tag(AppPreferences.TerminalCursorStyle.block)
            Text("Underline")
                .tag(AppPreferences.TerminalCursorStyle.underline)
            Text("Bar")
                .tag(AppPreferences.TerminalCursorStyle.bar)
        }
        .frame(width: inputWidth)
    }

    private var cursorBlink: some View {
        HStack {
            Toggle("Cursor Blink", isOn: $prefs.preferences.terminal.cursorBlink)
            Text("Blink cursor")
        }
    }

    private var optionAsMetaToggle: some View {
        HStack {
            Toggle("Option as Meta", isOn: $prefs.preferences.terminal.optionAsMeta)
            Text("Use \"Option\" key as \"Meta\"")
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        Picker("Font:", selection: $prefs.preferences.terminal.font.customFont) {
            Text("System Font")
                .tag(false)
            Text("Custom")
                .tag(true)
        }
        .frame(width: inputWidth)
        if prefs.preferences.terminal.font.customFont {
            FontPicker(
                "\(prefs.preferences.terminal.font.name) \(prefs.preferences.terminal.font.size)",
                name: $prefs.preferences.terminal.font.name, size: $prefs.preferences.terminal.font.size
            )
        }
    }
}
