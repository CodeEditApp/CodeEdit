//
//  SettingsPage.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 30/03/23.
//

import Foundation
import SwiftUI

/// A struct for a settings page
struct SettingsPage: Hashable, Equatable, Identifiable {
    /// Default intializer
    internal init(
        _ name: Name,
        baseColor: Color? = nil,
        icon: IconResource? = nil,
        isSetting: Bool = false,
        displayName: String = ""
    ) {
        self.name = name
        self.baseColor = baseColor ?? .red
        self.icon = icon ?? .system("questionmark.app")
        self.isSetting = isSetting
        self.displayName = displayName
    }

    // TODO: This is a very hacky fix, find out if there is a better way to do this
    var id: Int = Int.random(in: 0...1000000)

    let name: Name
    let baseColor: Color
    let isSetting: Bool
    let displayName: String
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
