//
//  ExtensionSettings.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

extension SettingsData {
    struct ExtensionSettings: Codable, Hashable, SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "Extensions",
                "Language Server",
                "LSP Binaries",
                "Linters",
                "Formatters",
                "Debug Protocol",
                "DAP",
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// Default initializer
        init() {}
    }
}
