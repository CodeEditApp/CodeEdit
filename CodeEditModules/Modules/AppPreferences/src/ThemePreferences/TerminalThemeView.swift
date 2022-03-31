//
//  TerminalThemeView.swift
//  
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI
import TerminalEmulator
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
    private var colors = AnsiColors.shared

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
            Text("ANSI Colors")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            HStack(spacing: 5) {
                PreferencesColorPicker($colors.colors[0])
                PreferencesColorPicker($colors.colors[1])
                PreferencesColorPicker($colors.colors[2])
                PreferencesColorPicker($colors.colors[3])
                PreferencesColorPicker($colors.colors[4])
                PreferencesColorPicker($colors.colors[5])
                PreferencesColorPicker($colors.colors[6])
                PreferencesColorPicker($colors.colors[7])
                Text("Normal").padding(.leading, 4)
            }
            HStack(spacing: 5) {
                PreferencesColorPicker($colors.colors[8])
                PreferencesColorPicker($colors.colors[9])
                PreferencesColorPicker($colors.colors[10])
                PreferencesColorPicker($colors.colors[11])
                PreferencesColorPicker($colors.colors[12])
                PreferencesColorPicker($colors.colors[13])
                PreferencesColorPicker($colors.colors[14])
                PreferencesColorPicker($colors.colors[15])
                Text("Bright").padding(.leading, 4)
            }
            Button("Restore Defaults") {
                AnsiColors.shared.resetDefault()
            }
            .padding(.top, 5)
        }
    }
}

struct TerminalThemeView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalThemeView()
            .preferredColorScheme(.dark)
    }
}
