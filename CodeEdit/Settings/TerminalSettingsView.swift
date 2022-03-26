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
	@AppStorage(TerminalColorScheme.storageKey) var terminalColorSchmeme: TerminalColorScheme = .default

	@StateObject private var colors = AnsiColors.shared

    var body: some View {
		Form {
			Picker("Terminal Shell".localized(), selection: $shellType) {
				Text("System Default".localized())
					.tag(TerminalShellType.auto)
				Divider()
				Text("ZSH")
					.tag(TerminalShellType.zsh)
				Text("Bash")
					.tag(TerminalShellType.bash)
			}

			Picker("Terminal Appearance", selection: $terminalColorSchmeme) {
				Text("App Default")
					.tag(TerminalColorScheme.auto)
				Divider()
				Text("Light")
					.tag(TerminalColorScheme.light)
				Text("Dark")
					.tag(TerminalColorScheme.dark)
			}

			Picker("Terminal Font".localized(), selection: $terminalFontSelection) {
				Text("System Font".localized())
					.tag(TerminalFont.systemFont)
				Divider()
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
		}
		.padding()
    }

	private func ansiColorPicker(_ color: Binding<Color>) -> some View {
		ColorPicker(selection: color, supportsOpacity: false) { }
			.labelsHidden()
	}
}

struct TerminalSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalSettingsView()
    }
}
