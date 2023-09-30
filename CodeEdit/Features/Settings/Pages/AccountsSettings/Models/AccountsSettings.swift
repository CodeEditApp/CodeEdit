//
//  AccountsPreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

extension SettingsData {

    /// The global settings for text editing
    struct AccountsSettings: Codable, Hashable, SearchableSettingsPage {
        /// An integer indicating how many spaces a `tab` will generate
        var sourceControlAccounts: GitAccounts = .init()

        /// The search keys
        var searchKeys: [String] {
            [
                "Accounts",
                "Delete Account...",
                "Add Account..."
            ]
            .map { NSLocalizedString($0, comment: "") }
        }

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.sourceControlAccounts = try container.decodeIfPresent(
                GitAccounts.self,
                forKey: .sourceControlAccounts
            ) ?? .init()
        }
    }

    struct GitAccounts: Codable, Hashable {
        /// This id will store the account name as the identifiable
        var gitAccounts: [SourceControlAccount] = []

        var sshKey: String = ""
        /// Default initializer
        init() {}
        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.gitAccounts = try container.decodeIfPresent([SourceControlAccount].self, forKey: .gitAccounts) ?? []
            self.sshKey = try container.decodeIfPresent(String.self, forKey: .sshKey) ?? ""
        }
    }
}
