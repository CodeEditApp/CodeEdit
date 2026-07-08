//
//  AccountsPreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

extension SettingsData {

    /// The global settings for source control accounts
    struct AccountsSettings: Codable, Hashable {
        /// The list of git accounts the user has saved
        @CodableDefault<DefaultGitAccounts> var sourceControlAccounts: GitAccounts = .init()

        /// Default initializer
        init() {}
    }

    struct GitAccounts: Codable, Hashable {
        /// This id will store the account name as the identifiable
        @CodableDefault<DefaultEmptySourceControlAccounts> var gitAccounts: [SourceControlAccount] = []

        @CodableDefault<DefaultEmptyString> var sshKey = ""

        /// Default initializer
        init() {}
    }
}
