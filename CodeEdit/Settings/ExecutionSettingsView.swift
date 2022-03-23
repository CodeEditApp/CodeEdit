//
//  ExecutionSettingsView.swift
//  CodeEdit
//
//  Created by 朱浩宇 on 2022/3/23.
//

import SwiftUI
import TerminalEmulator

struct ExecutionSettingsView: View {
    @AppStorage(TerminalShellType.storageKey) var shellType: TerminalShellType = .default

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

            Spacer()
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
