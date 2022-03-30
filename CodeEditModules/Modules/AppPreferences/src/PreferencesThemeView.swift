//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import CodeFile
import FontPicker
import SwiftUI
import Preferences
import TerminalEmulator

public struct PreferencesThemeView: View {

    @AppStorage(CodeFileView.Theme.storageKey)
    var editorTheme: CodeFileView.Theme = .atelierSavannaAuto

    @AppStorage(TerminalShellType.storageKey)
    var shellType: TerminalShellType = .default

    @AppStorage(TerminalFont.storageKey)
    var terminalFontSelection: TerminalFont = .default

    @AppStorage(TerminalFontName.storageKey)
    var terminalFontName: String = TerminalFontName.default

    @AppStorage(TerminalFontSize.storageKey)
    var terminalFontSize: Int = TerminalFontSize.default

    @AppStorage(TerminalColorScheme.storageKey)
    var terminalColorSchmeme: TerminalColorScheme = .default

    @StateObject
    private var colors = AnsiColors.shared

    public init() {}

    public var body: some View {
        TabView {
            editor
                .padding()
                .tabItem {
                    Text("Editor")
                }
            terminal
                .padding()
                .tabItem {
                    Text("Terminal")
                }
        }
        .frame(width: 844)
        .padding(30)
    }

    private var editor: some View {
        Form {
            Picker("Editor Theme", selection: $editorTheme) {
                Text("Atelier Savanna (Auto)")
                    .tag(CodeFileView.Theme.atelierSavannaAuto)
                Text("Atelier Savanna Dark")
                    .tag(CodeFileView.Theme.atelierSavannaDark)
                Text("Atelier Savanna Light")
                    .tag(CodeFileView.Theme.atelierSavannaLight)
                Text("Agate")
                    .tag(CodeFileView.Theme.agate)
                Text("Ocean")
                    .tag(CodeFileView.Theme.ocean)
            }
            .fixedSize()
        }
    }

    private var terminal: some View {
        Form {
            Picker("Terminal Shell", selection: $shellType) {
                Text("System Default")
                    .tag(TerminalShellType.auto)
                Divider()
                Text("ZSH")
                    .tag(TerminalShellType.zsh)
                Text("Bash")
                    .tag(TerminalShellType.bash)
            }
            .fixedSize()

            Picker("Terminal Appearance", selection: $terminalColorSchmeme) {
                Text("App Default")
                    .tag(TerminalColorScheme.auto)
                Divider()
                Text("Light")
                    .tag(TerminalColorScheme.light)
                Text("Dark")
                    .tag(TerminalColorScheme.dark)
            }
            .fixedSize()

            Picker("Terminal Font", selection: $terminalFontSelection) {
                Text("System Font")
                    .tag(TerminalFont.systemFont)
                Divider()
                Text("Custom")
                    .tag(TerminalFont.custom)
            }
            .fixedSize()
            if terminalFontSelection == .custom {
                FontPicker(
                    "\(terminalFontName) \(terminalFontSize)",
                    name: $terminalFontName,
                    size: $terminalFontSize
                )
            }
            Divider()
                .frame(maxWidth: 400)
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        ansiColorPicker($colors.colors[0])
                        ansiColorPicker($colors.colors[1])
                        ansiColorPicker($colors.colors[2])
                        ansiColorPicker($colors.colors[3])
                        ansiColorPicker($colors.colors[4])
                        ansiColorPicker($colors.colors[5])
                        ansiColorPicker($colors.colors[6])
                        ansiColorPicker($colors.colors[7])
                        Text("Normal").padding(.leading, 4)
                    }
                    HStack(spacing: 0) {
                        ansiColorPicker($colors.colors[8])
                        ansiColorPicker($colors.colors[9])
                        ansiColorPicker($colors.colors[10])
                        ansiColorPicker($colors.colors[11])
                        ansiColorPicker($colors.colors[12])
                        ansiColorPicker($colors.colors[13])
                        ansiColorPicker($colors.colors[14])
                        ansiColorPicker($colors.colors[15])
                        Text("Bright").padding(.leading, 4)
                    }
                }
            }
            Button("Restore Defaults") {
                AnsiColors.shared.resetDefault()
            }
        }
    }

    private func ansiColorPicker(_ color: Binding<Color>) -> some View {
        ColorPicker(selection: color, supportsOpacity: false) { }
            .labelsHidden()
    }
}
