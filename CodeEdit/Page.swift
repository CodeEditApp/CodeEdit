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

