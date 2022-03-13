//
//  GeneralSettingsView.swift
//  CodeEdit
//
//  Created by Pavel Kasila on 11.03.22.
//

import SwiftUI

// MARK: - Data

enum Appearances: String, CaseIterable, Hashable {
    case system
    case light
    case dark
    
    func applyAppearance() {
        switch self {
        case .system:
            NSApp.appearance = nil
            break
        case .dark:
            NSApp.appearance = .init(named: .darkAqua)
            break
        case .light:
            NSApp.appearance = .init(named: .aqua)
            break
        }
    }
    
    static let appearanceStorageKey = "appearance"
}

// MARK: - View

struct GeneralSettingsView: View {
    @AppStorage(Appearances.appearanceStorageKey) var appearance: Appearances = Appearances.system
    
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
        }
        .padding()
        
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
