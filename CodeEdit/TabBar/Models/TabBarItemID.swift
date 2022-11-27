//
//  TabBarItemID.swift
//  
//
//  Created by Pavel Kasila on 30.04.22.
//

import Foundation

/// Enum to represent item's ID to tab bar
enum TabBarItemID: Codable, Identifiable, Hashable {
    var id: String {
        switch self {
        case .codeEditor(let path):
            return "codeEditor_\(path)"
        case .extensionInstallation(let id):
            return "extensionInstallation_\(id.uuidString)"
        }
    }

    /// Represents code editor tab
    case codeEditor(String)

    /// Represents extension installation tab
    case extensionInstallation(UUID)
}
