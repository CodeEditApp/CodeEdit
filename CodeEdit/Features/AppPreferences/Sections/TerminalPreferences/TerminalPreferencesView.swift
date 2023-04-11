//
//  TerminalPreferencesView.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 02.04.22.
//

import SwiftUI
import Preferences

/// A view that implements the `Terminal` preference section
struct TerminalPreferencesView: View {
    private let inputWidth: Double = 150

    @StateObject
    private var prefs: SettingsModel = .shared

    init() {}

    var body: some View {
        PreferencesContent {
            shellSection
            fontSection
            cursorSection
        }
    }
}

private extension TerminalPreferencesView {
    private var shellSection: some View {
        PreferencesSection("Shell") {
            shellSelector
            optionAsMetaToggle
        }
    }

    private var fontSection: some View {
        PreferencesSection("Font") {
            fontSelector
        }
    }

    private var cursorSection: some View {
        PreferencesSection("Cursor") {
            cursorStyle
            cursorBlink
        }
    }

    @ViewBuilder
    private var shellSelector: some View {
        Picker("Shell:", selection: $prefs.preferences.terminal.shell) {
            Text("System Default")
                .tag(Settings.TerminalShell.system)
            Divider()
            Text("ZSH")
                .tag(Settings.TerminalShell.zsh)
            Text("Bash")
                .tag(Settings.TerminalShell.bash)
        }
        .frame(width: inputWidth)
    }

    private var cursorStyle: some View {
        Picker("Terminal Cursor Style: ", selection: $prefs.preferences.terminal.cursorStyle) {
            Text("Block")
                .tag(Settings.TerminalCursorStyle.block)
            Text("Underline")
                .tag(Settings.TerminalCursorStyle.underline)
            Text("Bar")
                .tag(Settings.TerminalCursorStyle.bar)
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
