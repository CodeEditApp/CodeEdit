//
//  LanguageServerSettings.swift
//  CodeEdit
//
//  Created by Abe Malla on 2/2/25.
//

import Foundation

extension SettingsData {
    struct LanguageServerSettings: Codable, Hashable, SearchableSettingsPage {

        /// The search keys
        var searchKeys: [String] {
            [
                "Language Servers",
                "LSP Binaries",
                "Linters",
                "Formatters",
                "Debug Protocol",
                "DAP",
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// Stores the currently installed language servers. The key is the name of the language server.
        @CodableDefault<DefaultEmptyLanguageServerDictionary>
        var installedLanguageServers: [String: InstalledLanguageServer] = [:]

        /// Default initializer
        init() {}
    }

    struct InstalledLanguageServer: Codable, Hashable {
        let packageName: String
        var isEnabled: Bool
        let version: String
    }
}
