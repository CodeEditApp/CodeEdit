//
//  TerminalThemeView.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI
import FontPicker

struct TerminalThemeView: View {
    @AppStorage(TerminalShellType.storageKey)
    var shellType: TerminalShellType = .default

    @AppStorage(TerminalFont.storageKey)
    var terminalFontSelection: TerminalFont = .custom

    @AppStorage(TerminalFontName.storageKey)
    var terminalFontName: String = TerminalFontName.default

    @AppStorage(TerminalFontSize.storageKey)
    var terminalFontSize: Int = TerminalFontSize.default

    @AppStorage(TerminalColorScheme.storageKey)
    var terminalColorSchmeme: TerminalColorScheme = .default

    @StateObject
    private var themeModel: ThemeModel = .shared

    @State private var darkTerminal: Bool = false

    init() {
        self._darkTerminal = .init(initialValue: terminalColorSchmeme == .dark)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .foregroundColor(Color(NSColor.controlBackgroundColor))
            VStack(alignment: .leading, spacing: 14) {
                topToggles
                shellSelector
                fontSelector
                Divider()
                ansiColorSelector
            }
            .padding(20)
        }
        .onChange(of: darkTerminal) { newValue in
            if newValue {
                terminalColorSchmeme = .dark
            } else {
                terminalColorSchmeme = .auto
            }
        }
    }

    private var topToggles: some View {
        VStack(alignment: .leading) {
            Toggle("Use dark terminal appearance", isOn: $darkTerminal)
        }
    }

    private var shellSelector: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Terminal Shell")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
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
            .labelsHidden()
        }
    }

    private var fontSelector: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Font")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            HStack {
                Picker("Terminal Font", selection: $terminalFontSelection) {
                    Text("System Font")
                        .tag(TerminalFont.systemFont)
                    Text("Custom")
                        .tag(TerminalFont.custom)
                }
                .fixedSize()
                .labelsHidden()
                if terminalFontSelection == .custom {
                    FontPicker("\(terminalFontName) \(terminalFontSize)",
                               name: $terminalFontName, size: $terminalFontSize)
                }
            }
        }
    }

    private var ansiColorSelector: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let selectedTheme = themeModel.selectedTheme,
               let index = themeModel.themes.firstIndex(of: selectedTheme) {
                Text("ANSI Colors")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 5)
                HStack(spacing: 5) {
                    PreferencesColorPicker($themeModel.themes[index].terminal.black.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.red.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.green.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.yellow.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.blue.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.magenta.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.cyan.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.white.swiftColor)
                    Text("Normal").padding(.leading, 4)
                }
                HStack(spacing: 5) {
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightBlack.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightRed.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightGreen.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightYellow.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightBlue.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightMagenta.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightCyan.swiftColor)
                    PreferencesColorPicker($themeModel.themes[index].terminal.brightWhite.swiftColor)
                    Text("Bright").padding(.leading, 4)
                }
                .padding(.top, 5)
            }
        }
    }
}

struct TerminalThemeView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalThemeView()
            .preferredColorScheme(.dark)
    }
}
