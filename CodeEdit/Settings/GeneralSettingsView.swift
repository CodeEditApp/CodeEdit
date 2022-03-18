//
//  GeneralSettingsView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 11.03.22.
//

import SwiftUI

// MARK: - View

struct GeneralSettingsView: View {
    @AppStorage(Appearances.storageKey) var appearance: Appearances = Appearances.default
    @AppStorage(ReopenBehavior.storageKey) var reopenBehavior: ReopenBehavior = ReopenBehavior.default
	@AppStorage(FileIconStyle.storageKey) var fileIconStyle: FileIconStyle = FileIconStyle.default
    
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
        }
        .padding()
        
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
