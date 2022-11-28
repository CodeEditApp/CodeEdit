//
//  AccountsPreferences.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

extension AppPreferences {

    /// The global settings for text editing
    struct AccountsPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        var sourceControlAccounts: GitAccounts = .init()

        /// Default initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.sourceControlAccounts = try container.decodeIfPresent(GitAccounts.self,
                                                                       forKey: .sourceControlAccounts) ?? .init()
        }
    }

    struct GitAccounts: Codable {
        /// This id will store the account name as the identifiable
        var gitAccount: [SourceControlAccounts] = []

        var sshKey: String = ""
        /// Default initializer
        init() {}
        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.gitAccount = try container.decodeIfPresent([SourceControlAccounts].self, forKey: .gitAccount) ?? []
            self.sshKey = try container.decodeIfPresent(String.self, forKey: .sshKey) ?? ""
        }
    }
}
