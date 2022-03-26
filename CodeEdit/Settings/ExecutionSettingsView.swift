//
//  ExecutionSettingsView.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/23.
//

import SwiftUI
import TerminalEmulator
import FontPicker
import Preferences

struct ExecutionSettingsView: View {
    @AppStorage(TerminalShellType.storageKey) var shellType: TerminalShellType = .default
    @AppStorage(TerminalFont.storageKey) var terminalFontSelection: TerminalFont = .default
    @AppStorage(TerminalFontName.storageKey) var terminalFontName: String = TerminalFontName.default
    @AppStorage(TerminalFontSize.storageKey) var terminalFontSize: Int = TerminalFontSize.default

    @State var customFont  = false

    @StateObject private var colors = AnsiColors.shared
    @State var terminalColor: Color = .gray

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .center) {
            Preferences.Container(contentWidth: 500) {
                Preferences.Section(title: "Terminal Shell:") {
                    Picker("", selection: $shellType) {
                        Text("System Default".localized())
                            .tag(TerminalShellType.auto)
                        Text("ZSH")
                            .tag(TerminalShellType.zsh)
                        Text("Bash")
                            .tag(TerminalShellType.bash)
                    }
                    .fixedSize()
                }

                Preferences.Section(title: "Terminal Font:") {
                    Toggle(isOn: $customFont) {
                        FontPicker("\(terminalFontName) \(terminalFontSize)",
                                   name: $terminalFontName, size: $terminalFontSize)
                    }
                }

                Preferences.Section(title: "Terminal Color:") {
                    if colorScheme == .dark {
                        HStack(spacing: 0) {
                            ansiColorPicker($colors.colors[0])
                            ansiColorPicker($colors.colors[1])
                            ansiColorPicker($colors.colors[2])
                            ansiColorPicker($colors.colors[3])
                            ansiColorPicker($colors.colors[4])
                            ansiColorPicker($colors.colors[5])
                            ansiColorPicker($colors.colors[6])
                            ansiColorPicker($colors.colors[7])
                        }
                    } else {
                        HStack(spacing: 0) {
                            ansiColorPicker($colors.colors[8])
                            ansiColorPicker($colors.colors[9])
                            ansiColorPicker($colors.colors[10])
                            ansiColorPicker($colors.colors[11])
                            ansiColorPicker($colors.colors[12])
                            ansiColorPicker($colors.colors[13])
                            ansiColorPicker($colors.colors[14])
                            ansiColorPicker($colors.colors[15])
                        }
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            customFont = terminalFontSelection == .custom
        }
        .padding()
        .frame(width: 820, height: 450)
    }

    private func ansiColorPicker(_ color: Binding<Color>) -> some View {
        ColorPicker(selection: color, supportsOpacity: false) { }
            .labelsHidden()
    }
}
