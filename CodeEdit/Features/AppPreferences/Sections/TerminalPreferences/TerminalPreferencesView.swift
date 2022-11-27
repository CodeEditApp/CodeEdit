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
