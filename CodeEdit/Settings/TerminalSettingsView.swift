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
	@AppStorage(AnsiColors.storageKey) var colors: AnsiColors = AnsiColors.default

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
			Divider()
			Section {
				VStack(alignment: .leading, spacing: 0) {
					HStack(spacing: 0) {
						ansiColorPicker($colors.black)
						ansiColorPicker($colors.red)
						ansiColorPicker($colors.green)
						ansiColorPicker($colors.yellow)
						ansiColorPicker($colors.blue)
						ansiColorPicker($colors.magenta)
						ansiColorPicker($colors.cyan)
						ansiColorPicker($colors.white)
						Text("Normal").padding(.leading, 4)
					}
					HStack(spacing: 0) {
						ansiColorPicker($colors.brightBlack)
						ansiColorPicker($colors.brightRed)
						ansiColorPicker($colors.brightGreen)
						ansiColorPicker($colors.brightYellow)
						ansiColorPicker($colors.brightBlue)
						ansiColorPicker($colors.brightMagenta)
						ansiColorPicker($colors.brightCyan)
						ansiColorPicker($colors.brightWhite)
						Text("Bright").padding(.leading, 4)
					}
				}
			}
		}
		.padding()
    }

	private func ansiColorPicker(_ color: Binding<CGColor>) -> some View {
		ColorPicker(selection: color, supportsOpacity: false) { }
			.labelsHidden()
	}
}

struct TerminalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalSettingsView()
    }
}
