//
//  Page.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 30/03/23.
//

import Foundation
import SwiftUI

enum Name: String {
    case generalSection = "App Preferences"

    case generalPreferences = "General"
    case accountPreferences = "Accounts"
    case behaviorPreferences = "Behaviors"
    case navigationPreferences = "Navigation"
    case themePreferences = "Themes"
    case textEditingPreferences = "Text Editing"
    case terminalPreferences = "Terminal"
    case keybindingsPreferences = "Key Bindings"
    case sourceControlPreferences = "Source Control"
    case componentsPreferences = "Components"
    case locationPreferences = "Locations"
    case advancedPreferences = "Advanced"
}

struct Page: Hashable, Identifiable {
    internal init(_ name: Name, icon: Icon? = nil, children: [Page] = []) {
        self.children = children
        self.name = name
        self.icon = icon ?? .init(baseColor: .red, systemName: "questionmark.app", icon: .system("questionmark.app"))
    }

    var id: String { name.rawValue }

    let name: Name
    let children: [Page]?
    var nameString: LocalizedStringKey { LocalizedStringKey(name.rawValue) }
    let icon: Icon

    struct Icon: Hashable {
        enum IconResource: Equatable, Hashable {
            case system(_ name: String)
        }

        let baseColor: Color
        let systemName: String
        let icon: IconResource
    }
}
