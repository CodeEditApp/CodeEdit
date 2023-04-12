//
//  TerminalSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct TerminalSettingsView: View {

    // MARK: View

    var body: some View {
        SettingsForm {
            shell
            font
            cursor
        }
    }

    @AppSettings var settings
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
        Picker("Shell", selection: $settings.terminal.shell) {
            Text("System Default")
                .tag(SettingsData.TerminalShell.system)
            Divider()
            Text("ZSH")
                .tag(SettingsData.TerminalShell.zsh)
            Text("Bash")
                .tag(SettingsData.TerminalShell.bash)
        }
    }

    private var cursorStyle: some View {
        Picker("Terminal Cursor Style", selection: $settings.terminal.cursorStyle) {
            Text("Block")
                .tag(SettingsData.TerminalCursorStyle.block)
            Text("Underline")
                .tag(SettingsData.TerminalCursorStyle.underline)
            Text("Bar")
                .tag(SettingsData.TerminalCursorStyle.bar)
        }
    }

    private var cursorBlink: some View {
        Group {
            Toggle("Blink Cursor", isOn: $settings.terminal.cursorBlink)
        }
    }

    private var optionAsMetaToggle: some View {
        Group {
            Toggle("Use \"Option\" key as \"Meta\"", isOn: $settings.terminal.optionAsMeta)
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        Group {
            Picker("Font", selection: $settings.terminal.font.customFont) {
                Text("System Font")
                    .tag(false)
                Text("Custom")
                    .tag(true)
            }
        }
        if settings.terminal.font.customFont {
            FontPicker(
                "\(settings.terminal.font.name) \(settings.terminal.font.size)",
                name: $settings.terminal.font.name, size: $settings.terminal.font.size
            )
        }
    }
}
