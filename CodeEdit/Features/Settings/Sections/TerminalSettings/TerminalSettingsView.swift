//
//  TerminalSettingsView.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 02.04.22.
//

import SwiftUI
import Settings

/// A view that implements the `Terminal` preference section
struct TerminalSettingsView: View {

    // MARK: - View

    var body: some View {
        SettingsContent {
            shellSection
            fontSection
            cursorSection
        }
            .frame(width: 715)
    }

    private let inputWidth: Double = 150

    @StateObject
    private var prefs: SettingsModel = .shared

    init() {}
}

private extension TerminalSettingsView {

    // MARK: - Sections

    private var shellSection: some View {
        SettingsSection("Shell") {
            shellSelector
            optionAsMetaToggle
        }
    }

    private var fontSection: some View {
        SettingsSection("Font") {
            fontSelector
        }
    }

    private var cursorSection: some View {
        SettingsSection("Cursor") {
            cursorStyle
            cursorBlink
        }
    }

    // MARK: - Preference Views

    @ViewBuilder
    private var shellSelector: some View {
        Picker("Shell:", selection: $prefs.settings.terminal.shell) {
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
        Picker("Terminal Cursor Style: ", selection: $prefs.settings.terminal.cursorStyle) {
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
            Toggle("Cursor Blink", isOn: $prefs.settings.terminal.cursorBlink)
            Text("Blink cursor")
        }
    }

    private var optionAsMetaToggle: some View {
        HStack {
            Toggle("Option as Meta", isOn: $prefs.settings.terminal.optionAsMeta)
            Text("Use \"Option\" key as \"Meta\"")
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        Picker("Font:", selection: $prefs.settings.terminal.font.customFont) {
            Text("System Font")
                .tag(false)
            Text("Custom")
                .tag(true)
        }
        .frame(width: inputWidth)
        if prefs.settings.terminal.font.customFont {
            FontPicker(
                "\(prefs.settings.terminal.font.name) \(prefs.settings.terminal.font.size)",
                name: $prefs.settings.terminal.font.name, size: $prefs.settings.terminal.font.size
            )
        }
    }
}
