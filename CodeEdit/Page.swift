//
//  Page.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 30/03/23.
//

import Foundation
import SwiftUI

/// An enum of all the settings tabs
enum Name: String {
    // MARK: - App Settings
    case settingsSection = "Settings"

    case generalSettings = "General"
    case accountSettings = "Accounts"
    case behaviorSettings = "Behaviors"
    case navigationSettings = "Navigation"
    case themeSettings = "Themes"
    case textEditingSettings = "Text Editing"
    case terminalSettings = "Terminal"
    case keybindingsSettings = "Key Bindings"
    case sourceControlSettings = "Source Control"
    case componentsSettings = "Components"
    case locationSettings = "Locations"
    case advancedSettings = "Advanced"
}

/// A struct for a settings tab
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
