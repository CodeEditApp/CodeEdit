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
    
    var body: some View {
        Form {
            Picker("Appearance", selection: $appearance) {
                Text("System")
                    .tag(Appearances.system)
                Divider()
                Text("Light")
                    .tag(Appearances.light)
                Text("Dark")
                    .tag(Appearances.dark)
            }
            .onChange(of: appearance) { tag in
                tag.applyAppearance()
            }
            
            Picker("Reopen Behavior", selection: $reopenBehavior) {
                Text("Open Panel")
                    .tag(ReopenBehavior.openPanel)
                Text("New Document")
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
