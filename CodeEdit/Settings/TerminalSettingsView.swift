//
//  TerminalSettingsView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 23.03.22.
//

import SwiftUI
import TerminalEmulator
import FontPicker

struct TerminalSettingsView: View {
	@AppStorage(TerminalShellType.storageKey) var shellType: TerminalShellType = .default
	@AppStorage(TerminalFont.storageKey) var terminalFontSelection: TerminalFont = .default
	@AppStorage(TerminalFontName.storageKey) var terminalFontName: String = TerminalFontName.default
	@AppStorage(TerminalFontSize.storageKey) var terminalFontSize: Int = TerminalFontSize.default

    var body: some View {
		Form {
			Picker("Terminal Shell".localized(), selection: $shellType) {
				Text("System Default".localized())
					.tag(TerminalShellType.auto)
				Text("ZSH")
					.tag(TerminalShellType.zsh)
				Text("Bash")
					.tag(TerminalShellType.bash)
			}

			Picker("Terminal Font".localized(), selection: $terminalFontSelection) {
				Text("System Font".localized())
					.tag(TerminalFont.systemFont)
				Text("Custom".localized())
					.tag(TerminalFont.custom)
			}
			if terminalFontSelection == .custom {
				HStack {
					FontPicker("\(terminalFontName) \(terminalFontSize)", name: $terminalFontName, size: $terminalFontSize)
				}
			}
		}
		.padding()
    }
}

struct TerminalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalSettingsView()
    }
}
