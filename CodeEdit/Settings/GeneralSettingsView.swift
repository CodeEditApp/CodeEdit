//
//  GeneralSettingsView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 11.03.22.
//

import SwiftUI
import CodeFile

// MARK: - View

struct GeneralSettingsView: View {
    @AppStorage(Appearances.storageKey) var appearance: Appearances = .default
    @AppStorage(ReopenBehavior.storageKey) var reopenBehavior: ReopenBehavior = .default
    @AppStorage(FileIconStyle.storageKey) var fileIconStyle: FileIconStyle = .default
    @AppStorage(CodeFileView.Theme.storageKey) var editorTheme: CodeFileView.Theme = .atelierSavannaAuto
    @AppStorage(TabWidth.storageKey) var defaultTabWidth: TabWidth = .default

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
                    .tag(CodeFileView.Theme.atelierSavannaAuto)
				Text("Atelier Savanna Dark")
                    .tag(CodeFileView.Theme.atelierSavannaDark)
				Text("Atelier Savanna Light")
                    .tag(CodeFileView.Theme.atelierSavannaLight)
				// TODO: Pojoaque does not seem to work (does not change from previous selection)
//				Text("Pojoaque")
//					.tag(CodeEditor.ThemeName.pojoaque)
				Text("Agate")
					.tag(CodeFileView.Theme.agate)
				Text("Ocean")
					.tag(CodeFileView.Theme.ocean)
			}

            Picker("Default Tab Width".localized(), selection: $defaultTabWidth) {
                ForEach(TabWidth.allCases) { tabWidth in
                    Text(String(format: NSLocalizedString("%d spaces", comment: ""), tabWidth.rawValue))
                        .tag(tabWidth)
                }
            }
            .onChange(of: defaultTabWidth) { CodeEditorTextView.tabWidth = $0.rawValue }
        }
        .padding()
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
