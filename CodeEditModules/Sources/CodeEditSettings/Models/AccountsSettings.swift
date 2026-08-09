//
//  AccountsPreferences.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import Foundation

/// The global settings for source control accounts
public struct AccountsSettings: SettingsSection {

    /// The top-level key this section occupies in `settings.json`.
    public static let settingsKey = "accounts"
    /// The list of git accounts the user has saved
    @CodableDefault<DefaultGitAccounts> public var sourceControlAccounts: GitAccounts = .init()

    /// Default initializer
    public init() {}

    public struct GitAccounts: Codable, Hashable {
        /// This id will store the account name as the identifiable
        @CodableDefault<DefaultEmptySourceControlAccounts> public var gitAccounts: [SourceControlAccount] = []

        @CodableDefault<DefaultEmptyString> public var sshKey = ""

        /// Default initializer
        public init() {}
    }
}
