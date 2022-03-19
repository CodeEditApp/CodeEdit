//
//  GeneralSettingsView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 11.03.22.
//

import SwiftUI
import CodeFile
import CodeEditor

// MARK: - View

struct GeneralSettingsView: View {
    @AppStorage(Appearances.storageKey) var appearance: Appearances = .default
    @AppStorage(ReopenBehavior.storageKey) var reopenBehavior: ReopenBehavior = .default
	  @AppStorage(FileIconStyle.storageKey) var fileIconStyle: FileIconStyle = .default
	  @AppStorage(CodeEditorTheme.storageKey) var editorTheme: CodeEditor.ThemeName = .atelierSavannaAuto
    var body: some View {
        Form {
			Picker("Appearance".localized(), selection: $appearance) {
				Text("System".localized())
                    .tag(Appearances.system)
                Divider()
				Text("Light".localized())
                    .tag(Appearances.light)
				Text("Dark".localized())
                    .tag(Appearances.dark)
            }
            .onChange(of: appearance) { tag in
                tag.applyAppearance()
            }

			Picker("File Icon Style".localized(), selection: $fileIconStyle) {
				Text("Color".localized())
					.tag(FileIconStyle.color)
				Text("Monochrome".localized())
					.tag(FileIconStyle.monochrome)
			}

			Picker("Reopen Behavior".localized(), selection: $reopenBehavior) {
                Text("Welcome Screen".localized())
                    .tag(ReopenBehavior.welcome)
                Divider()
				Text("Open Panel".localized())
                    .tag(ReopenBehavior.openPanel)
				Text("New Document".localized())
                    .tag(ReopenBehavior.newDocument)
            }

			Picker("Editor Theme".localized(), selection: $editorTheme) {
				Text("Atelier Savanna (Auto)")
					.tag(CodeEditor.ThemeName.atelierSavannaAuto)
				Text("Atelier Savanna Dark")
					.tag(CodeEditor.ThemeName.atelierSavannaDark)
				Text("Atelier Savanna Light")
					.tag(CodeEditor.ThemeName.atelierSavannaLight)
				// TODO: Pojoaque does not seem to work (does not change from previous selection)
//				Text("Pojoaque")
//					.tag(CodeEditor.ThemeName.pojoaque)
				Text("Agate")
					.tag(CodeEditor.ThemeName.agate)
				Text("Ocean")
					.tag(CodeEditor.ThemeName.ocean)
				Text("Xcode")
                    .tag(CodeEditor.ThemeName.xcode)
                Text("Github")
                    .tag(CodeEditor.ThemeName.github)
                Text("Google Code")
                    .tag(CodeEditor.ThemeName.googlecode)
                Text("Visual Studio")
                    .tag(CodeEditor.ThemeName.vs)
			}
        }
        .padding()
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
