//
//  ExecutionSettingsView.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/23.
//

import SwiftUI
import TerminalEmulator
import FontPicker

struct ExecutionSettingsView: View {
    @AppStorage(TerminalShellType.storageKey) var shellType: TerminalShellType = .default
    @AppStorage(TerminalFont.storageKey) var terminalFontSelection: TerminalFont = .default
    @AppStorage(TerminalFontName.storageKey) var terminalFontName: String = TerminalFontName.default
    @AppStorage(TerminalFontSize.storageKey) var terminalFontSize: Int = TerminalFontSize.default

    @State var customFont  = false

    var body: some View {
        VStack {
            Picker("Terminal Shell".localized(), selection: $shellType) {
                Text("System Default".localized())
                    .tag(TerminalShellType.auto)
                Text("ZSH")
                    .tag(TerminalShellType.zsh)
                Text("Bash")
                    .tag(TerminalShellType.bash)
            }
            .fixedSize()

            HStack {
                Toggle("Custom Terminal Font:", isOn: $customFont)
                FontPicker("\(terminalFontName) \(terminalFontSize)",
                           name: $terminalFontName, size: $terminalFontSize)
            }

            Spacer()
        }
        .onAppear {
            customFont = terminalFontSelection == .custom
        }
        .frame(width: 820, height: 450)
        .padding()
    }
}

struct ExecutionSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ExecutionSettingsView()
    }
}
