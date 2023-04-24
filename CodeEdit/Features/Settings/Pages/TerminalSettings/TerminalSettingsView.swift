//
//  TerminalSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct TerminalSettingsView: View {
    @AppSettings var settings

    var body: some View {
        SettingsForm {
            Section {
                shellSelector
                optionAsMetaToggle
            }
            Section {
                useTextEditorFontToggle
                if !settings.terminal.useTextEditorFont {
                    fontSelector
                    fontSizeSelector
                }
            }
            Section {
                cursorStyle
                cursorBlink
            }
        }
    }
}

private extension TerminalSettingsView {
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
        Toggle("Blink Cursor", isOn: $settings.terminal.cursorBlink)
    }

    private var optionAsMetaToggle: some View {
        Toggle("Use \"Option\" key as \"Meta\"", isOn: $settings.terminal.optionAsMeta)
    }

    private var useTextEditorFontToggle: some View {
        Toggle("Use text editor font", isOn: $settings.terminal.useTextEditorFont)
    }

    @ViewBuilder
    private var fontSelector: some View {
        MonospacedFontPicker(title: "Font", selectedFontName: $settings.terminal.font.name)
            .onChange(of: settings.terminal.font.name) { fontName in
                settings.terminal.font.customFont = fontName != "SF Mono"
            }
    }

    private var fontSizeSelector: some View {
        Stepper(
            "Font Size",
            value: $settings.terminal.font.size,
            in: 1...288,
            step: 1,
            format: .number
        )
    }
}
