//
//  TerminalSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

/// A view that implements the `Terminal` settings page
struct TerminalSettingsView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        Form {
            shell
            font
            cursor
        }
            .formStyle(.grouped)
    }
}

private extension TerminalSettingsView {
    // MARK: Sections

    @ViewBuilder
    private var shell: some View {
        shellSelector
        optionAsMetaToggle
    }

    private var font: some View {
        fontSelector
    }

    @ViewBuilder
    private var cursor: some View {
        cursorStyle
        cursorBlink
    }

    // MARK: Preference Views

    @ViewBuilder
    private var shellSelector: some View {
        Picker("Shell", selection: $prefs.preferences.terminal.shell) {
            Text("System Default")
                .tag(AppPreferences.TerminalShell.system)
            Divider()
            Text("ZSH")
                .tag(AppPreferences.TerminalShell.zsh)
            Text("Bash")
                .tag(AppPreferences.TerminalShell.bash)
        }
    }

    private var cursorStyle: some View {
        Picker("Terminal Cursor Style", selection: $prefs.preferences.terminal.cursorStyle) {
            Text("Block")
                .tag(AppPreferences.TerminalCursorStyle.block)
            Text("Underline")
                .tag(AppPreferences.TerminalCursorStyle.underline)
            Text("Bar")
                .tag(AppPreferences.TerminalCursorStyle.bar)
        }
    }

    private var cursorBlink: some View {
        Group {
            Toggle("Blink Cursor", isOn: $prefs.preferences.terminal.cursorBlink)
        }
    }

    private var optionAsMetaToggle: some View {
        Group {
            Toggle("Use \"Option\" key as \"Meta\"", isOn: $prefs.preferences.terminal.optionAsMeta)
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        Group {
            Picker("Font", selection: $prefs.preferences.terminal.font.customFont) {
                Text("System Font")
                    .tag(false)
                Text("Custom")
                    .tag(true)
            }
        }
        if prefs.preferences.terminal.font.customFont {
            FontPicker(
                "\(prefs.preferences.terminal.font.name) \(prefs.preferences.terminal.font.size)",
                name: $prefs.preferences.terminal.font.name, size: $prefs.preferences.terminal.font.size
            )
        }
    }
}
