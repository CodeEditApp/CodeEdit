//
//  TerminalSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct TerminalSettingsView: View {
    @AppSettings(\.terminal)
    var settings

    var body: some View {
        SettingsForm {
            Section {
                shellSelector
                optionAsMetaToggle
            }
            Section {
                useTextEditorFontToggle
                if !settings.useTextEditorFont {
                    fontSelector
                    fontSizeSelector
                }
            }
            Section {
                cursorStyle
                cursorBlink
            }
            Section {
                injectionOptions
                useLoginShell
            }
        }
    }
}

private extension TerminalSettingsView {
    @ViewBuilder private var shellSelector: some View {
        Picker("Shell", selection: $settings.shell) {
            Text("System Default")
                .tag(SettingsData.TerminalShell.system)
            Divider()
            Text("Zsh")
                .tag(SettingsData.TerminalShell.zsh)
            Text("Bash")
                .tag(SettingsData.TerminalShell.bash)
        }
    }

    private var cursorStyle: some View {
        Picker("Terminal Cursor Style", selection: $settings.cursorStyle) {
            Text("Block")
                .tag(SettingsData.TerminalCursorStyle.block)
            Text("Underline")
                .tag(SettingsData.TerminalCursorStyle.underline)
            Text("Bar")
                .tag(SettingsData.TerminalCursorStyle.bar)
        }
    }

    private var cursorBlink: some View {
        Toggle("Blink Cursor", isOn: $settings.cursorBlink)
    }

    private var optionAsMetaToggle: some View {
        Toggle("Use \"Option\" key as \"Meta\"", isOn: $settings.optionAsMeta)
    }

    private var useTextEditorFontToggle: some View {
        Toggle("Use text editor font", isOn: $settings.useTextEditorFont)
    }

    @ViewBuilder private var fontSelector: some View {
        MonospacedFontPicker(title: "Font", selectedFontName: $settings.font.name)
    }

    private var fontSizeSelector: some View {
        Stepper(
            "Font Size",
            value: $settings.font.size,
            in: 1...288,
            step: 1,
            format: .number
        )
    }

    @ViewBuilder private var injectionOptions: some View {
        VStack {
            Toggle("Shell Integration", isOn: $settings.useShellIntegration)
            // swiftlint:disable:next line_length
                .help("CodeEdit supports integrating with common shells such as Bash and Zsh. This enables features like terminal title detection.")
            if !settings.useShellIntegration {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color(NSColor.systemYellow))
                    Text("Warning: Disabling integration disables features such as terminal title detection.")
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder private var useLoginShell: some View {
        if settings.useShellIntegration {
            Toggle("Use Login Shell", isOn: $settings.useLoginShell)
            // swiftlint:disable:next line_length
                .help("Whether or not to use a login shell when starting a terminal session. By default, a login shell is used used similar to Terminal.app.")
        } else {
            EmptyView()
        }
    }
}
