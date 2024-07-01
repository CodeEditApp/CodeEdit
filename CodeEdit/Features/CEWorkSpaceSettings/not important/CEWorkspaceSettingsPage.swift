//
//  CEWorkspaceSettingsPage.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import Foundation
import SwiftUI

/// Represents a workspace settings tab.
struct CEWorkspaceSettingsPage: Hashable, Equatable, Identifiable {
    /// Sidebar icon, with a base color and SF Symbol
    enum IconResource: Equatable, Hashable {
        case system(_ name: String)
        case symbol(_ name: String)
        case asset(_ name: String)
    }

    /// All the workspace settings pages
    enum Name: String {
        case project = "Project"
        case tasks = "Tasks"
    }

    let id: UUID = UUID()

    let name: Name
    let baseColor: Color?
    let isSetting: Bool
    let settingName: String
    var nameString: LocalizedStringKey {
        LocalizedStringKey(name.rawValue)
    }
    let icon: IconResource?

    init(
        _ name: Name,
        baseColor: Color? = nil,
        icon: IconResource? = nil,
        isSetting: Bool = false,
        settingName: String = ""
    ) {
        self.name = name
        self.baseColor = baseColor
        self.icon = icon
        self.isSetting = isSetting
        self.settingName = settingName
    }
}
