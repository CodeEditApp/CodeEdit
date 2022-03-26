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

    var body: some View {
        VStack(alignment: .center) {
            Preferences.Container(contentWidth: 450) {
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

                Preferences.Section(title: "Custom Terminal Font:") {
                    Toggle(isOn: $customFont) {
                        FontPicker("\(terminalFontName) \(terminalFontSize)",
                                   name: $terminalFontName, size: $terminalFontSize)
                    }
                }

                Preferences.Section(title: "Terminal Color:") {
                    CEColorPicker(selection: $terminalColor, colors: [.blue])
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
}
