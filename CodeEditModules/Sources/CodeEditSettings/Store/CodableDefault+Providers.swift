//
//  CodableDefault+Providers.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 07.04.26.
//

import AppKit

// MARK: - Bool Defaults

public enum DefaultTrue: DefaultValueProvider {
    public static let defaultValue = true
}

public enum DefaultFalse: DefaultValueProvider {
    public static let defaultValue = false
}

// MARK: - Terminal Defaults

public enum DefaultTerminalShell: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = TerminalSettings.Shell.system
}

public enum DefaultTerminalCursorStyle: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = TerminalSettings.CursorStyle.block
}

public enum DefaultTerminalFont: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = TerminalSettings.Font()
}

// MARK: - Navigation Defaults

public enum DefaultNavigationStyle: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = NavigationSettings.NavigationStyle.openInTabs
}

// MARK: - Collection Defaults

public enum DefaultEmptyGlobPatterns: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue: [GlobPattern] = []
}

public enum DefaultEmptyStringDictionary: DefaultValueProvider {
    public static let defaultValue: [String: String] = [:]
}

public enum DefaultEmptyLanguageServerDictionary: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue: [String: LanguageServerSettings.Installed] = [:]
}

// MARK: - Account Defaults

public enum DefaultGitAccounts: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = AccountsSettings.GitAccounts()
}

public enum DefaultEmptySourceControlAccounts: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue: [SourceControlAccount] = []
}

public enum DefaultEmptyString: DefaultValueProvider {
    public static let defaultValue = ""
}

// MARK: - General Settings Defaults

public enum DefaultAppearance: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.Appearances.system
}

public enum DefaultIssues: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.Issues.inline
}

public enum DefaultFileExtensionsVisibility: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.FileExtensionsVisibility.showAll
}

public enum DefaultFileExtensions: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.FileExtensions.default
}

public enum DefaultFileIconStyle: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.FileIconStyle.color
}

public enum DefaultSidebarTabBarPositionTop: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.SidebarTabBarPosition.top
}

public enum DefaultReopenBehavior: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.ReopenBehavior.welcome
}

public enum DefaultReopenWindowBehavior: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.ReopenWindowBehavior.doNothing
}

public enum DefaultProjectNavigatorSize: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.ProjectNavigatorSize.medium
}

public enum DefaultNavigatorDetail: DefaultValueProvider {
    nonisolated(unsafe) public static let defaultValue = GeneralSettings.NavigatorDetail.upTo3
}
