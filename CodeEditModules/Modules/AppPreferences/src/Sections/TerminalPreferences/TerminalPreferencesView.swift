//
//  TerminalPreferencesView.swift
//  
//
//  Created by Lukas Pistrol on 02.04.22.
//

import SwiftUI
import Preferences
import FontPicker

/// A view that implements the `Terminal` preference section
public struct TerminalPreferencesView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
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
        if prefs.preferences.terminal.font.customFont {
            FontPicker(
                "\(prefs.preferences.terminal.font.name) \(prefs.preferences.terminal.font.size)",
                name: $prefs.preferences.terminal.font.name, size: $prefs.preferences.terminal.font.size
            )
        }
    }
}
