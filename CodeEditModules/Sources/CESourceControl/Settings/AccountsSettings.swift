//
//  AccountsSettings.swift
//  CodeEditModules/Settings
//
//  Created by Nanashi Li on 2022/04/08.
//

import CodeEditSettings
import Foundation

/// The user's source-control accounts.
///
/// Lives in `CESourceControl` rather than with the app-wide settings models because its entire
/// contents are source control: `sourceControlAccounts` holds `[SourceControlAccount]` and an SSH
/// key, and nothing else. The general-sounding name is historical.
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

// MARK: - Defaults

public enum DefaultGitAccounts: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = AccountsSettings.GitAccounts()
}

public enum DefaultEmptySourceControlAccounts: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue: [SourceControlAccount] = []
}
