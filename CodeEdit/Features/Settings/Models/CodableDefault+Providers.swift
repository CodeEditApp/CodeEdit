//
//  CodableDefault+Providers.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07.04.26.
//

import AppKit
import CodeEditSettings

// MARK: - Bool Defaults

enum DefaultTrue: DefaultValueProvider {
    static let defaultValue = true
}

enum DefaultFalse: DefaultValueProvider {
    static let defaultValue = false
}

// MARK: - Terminal Defaults

enum DefaultTerminalShell: DefaultValueProvider {
    static let defaultValue = SettingsData.TerminalShell.system
}

enum DefaultTerminalCursorStyle: DefaultValueProvider {
    static let defaultValue = SettingsData.TerminalCursorStyle.block
}

enum DefaultTerminalFont: DefaultValueProvider {
    static let defaultValue = SettingsData.TerminalFont()
}

// MARK: - Navigation Defaults

enum DefaultNavigationStyle: DefaultValueProvider {
    static let defaultValue = SettingsData.NavigationStyle.openInTabs
}

// MARK: - Collection Defaults

enum DefaultEmptyGlobPatterns: DefaultValueProvider {
    static let defaultValue: [GlobPattern] = []
}

enum DefaultEmptyStringDictionary: DefaultValueProvider {
    static let defaultValue: [String: String] = [:]
}

enum DefaultEmptyLanguageServerDictionary: DefaultValueProvider {
    static let defaultValue: [String: SettingsData.InstalledLanguageServer] = [:]
}

// MARK: - Account Defaults

enum DefaultGitAccounts: DefaultValueProvider {
    static let defaultValue = SettingsData.GitAccounts()
}

enum DefaultEmptySourceControlAccounts: DefaultValueProvider {
    static let defaultValue: [SourceControlAccount] = []
}

enum DefaultEmptyString: DefaultValueProvider {
    static let defaultValue = ""
}

// MARK: - General Settings Defaults

enum DefaultAppearance: DefaultValueProvider {
    static let defaultValue = SettingsData.Appearances.system
}

enum DefaultIssues: DefaultValueProvider {
    static let defaultValue = SettingsData.Issues.inline
}

enum DefaultFileExtensionsVisibility: DefaultValueProvider {
    static let defaultValue = SettingsData.FileExtensionsVisibility.showAll
}

enum DefaultFileExtensions: DefaultValueProvider {
    static let defaultValue = SettingsData.FileExtensions.default
}

enum DefaultFileIconStyle: DefaultValueProvider {
    static let defaultValue = SettingsData.FileIconStyle.color
}

enum DefaultSidebarTabBarPositionTop: DefaultValueProvider {
    static let defaultValue = SettingsData.SidebarTabBarPosition.top
}

enum DefaultReopenBehavior: DefaultValueProvider {
    static let defaultValue = SettingsData.ReopenBehavior.welcome
}

enum DefaultReopenWindowBehavior: DefaultValueProvider {
    static let defaultValue = SettingsData.ReopenWindowBehavior.doNothing
}

enum DefaultProjectNavigatorSize: DefaultValueProvider {
    static let defaultValue = SettingsData.ProjectNavigatorSize.medium
}

enum DefaultNavigatorDetail: DefaultValueProvider {
    static let defaultValue = SettingsData.NavigatorDetail.upTo3
}
