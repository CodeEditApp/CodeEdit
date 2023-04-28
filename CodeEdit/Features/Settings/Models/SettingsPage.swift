//
//  SettingsPage.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 30/03/23.
//

import Foundation
import SwiftUI

/// A struct for a preferences tab
struct SettingsPage: Hashable, Identifiable {
    /// Default intializer
    internal init(
        _ name: Name,
        baseColor: Color? = nil,
        icon: IconResource? = nil,
        hideName: Bool? = false,
        children: [SettingsPage] = []
    ) {
        self.children = children
        self.name = name
        self.baseColor = baseColor ?? .red
        self.icon = icon ?? .system("questionmark.app")
        self.hideName = hideName
    }

    var id: String { name.rawValue }

    let name: Name
    let baseColor: Color
    let children: [SettingsPage]
    let hideName: Bool?
    var nameString: LocalizedStringKey { LocalizedStringKey(name.rawValue) }
    let icon: IconResource?

    /// A struct for a sidebar icon, with a base color and SF Symbol
    enum IconResource: Equatable, Hashable {
        case system(_ name: String)
        case symbol(_ name: String)
        case asset(_ name: String)
    }

    /// An enum of all the preferences tabs
    enum Name: String {
        // MARK: - App Preferences
        case general = "General"
        case accounts = "Accounts"
        case behavior = "Behaviors"
        case navigation = "Navigation"
        case theme = "Themes"
        case textEditing = "Text Editing"
        case terminal = "Terminal"
        case keybindings = "Key Bindings"
        case sourceControl = "Source Control"
        case components = "Components"
        case location = "Locations"
        case advanced = "Advanced"
    }

}
