//
//  Page.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 30/03/23.
//

import Foundation
import SwiftUI

/// An enum of all the preferences tabs
enum Name: String {
    // MARK: - App Preferences
    case appPreferencesSection = "App Preferences"

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

/// A struct for a preferences tab
struct Page: Hashable, Identifiable {
    /// Default intializer
    internal init(_ name: Name, icon: Icon? = nil, children: [Page] = []) {
        self.children = children
        self.name = name
        // If no icon is found, will default to a red question mark
        self.icon = icon ?? .init(baseColor: .red, systemName: "questionmark.app", icon: .system("questionmark.app"))
    }

    var id: String { name.rawValue }

    let name: Name
    // Optional because some Pages do not have any children
    let children: [Page]?
    var nameString: LocalizedStringKey { LocalizedStringKey(name.rawValue) }
    let icon: Icon

    /// A struct for a sidebar icon, with a base color and SF Symbol
    struct Icon: Hashable {
        enum IconResource: Equatable, Hashable {
            case system(_ name: String)
        }

        let baseColor: Color
        let systemName: String
        let icon: IconResource
    }
}
