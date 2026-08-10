//
//  SettingsData+Search.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom.
//

import CELSP
import Foundation
import CodeEditSettings

// App-side settings-search support. `searchKeys` are localized UI labels for the
// settings search feature (presentation, not preference data), so they live in the
// app rather than the CodeEditSettings package. One conformance extension per
// persisted settings page, plus `propertiesOf`.

extension GeneralSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        [
            "Appearance",
            "File Icon Style",
            "Tab Bar Style",
            "Show Jump Bar",
            "Dim editors without focus",
            "Navigator Tab Bar Position",
            "Inspector Tab Bar Position",
            "Show Issues",
            "Show Live Issues",
            "Automatically save change to disk",
            "Automatically reveal in project navigator",
            "Reopen Behavior",
            "After the last window is closed",
            "File Extensions",
            "Project Navigator Size",
            "Find Navigator Detail",
            "Issue Navigator Detail",
            "Show “Open With CodeEdit“ option in Finder",
            "'codeedit' Shell command",
            "Dialog Warnings",
            "Check for updates",
            "Automatically check for app updates",
            "Include pre-release versions"
        ]
        .map { NSLocalizedString($0, comment: "") }
    }
}

extension AccountsSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        [
            "Accounts",
            "Delete Account...",
            "Add Account..."
        ]
        .map { NSLocalizedString($0, comment: "") }
    }
}

extension NavigationSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        [
            "Navigation Style",
        ]
        .map { NSLocalizedString($0, comment: "") }
    }
}

extension ThemeSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        [
            "Automatically Change theme based on system appearance",
            "Always use dark terminal appearance",
            "Use theme background",
            "Light Appearance",
            "GitHub Light",
            "Xcode Light",
            "Solarized Light",
            "Solarized Dark",
            "Midnight",
            "Xcode Dark",
            "GitHub Dark"
        ]
        .map { NSLocalizedString($0, comment: "") }
    }
}

extension TextEditingSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        var keys = [
            "Prefer Indent Using",
            "Tab Width",
            "Wrap lines to editor width",
            "Editor Overscroll",
            "Font",
            "Font Size",
            "Font Weight",
            "Line Height",
            "Letter Spacing",
            "Autocomplete braces",
            "Enable type-over completion",
            "Bracket Pair Emphasis",
            "Bracket Pair Highlight",
            "Show Gutter",
            "Show Minimap",
            "Reformat at Column",
            "Show Reformatting Guide",
            "Invisibles",
            "Warning Characters"
        ]
        if #available(macOS 14.0, *) {
            keys.append("System Cursor")
        }
        return keys.map { NSLocalizedString($0, comment: "") }
    }
}

extension TerminalSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        [
            "Shell",
            "Use \"Option\" key as \"Meta\"",
            "Use text editor font",
            "Font",
            "Font Size",
            "Terminal Cursor Style",
            "Blink Cursor"
        ]
        .map { NSLocalizedString($0, comment: "") }
    }
}

extension SourceControlSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        [
            "General",
            "Enable source control",
            "Refresh local status automatically",
            "Fetch and refresh server status automatically",
            "Add and remove files automatically",
            "Select files to commit automatically",
            "Show source control changes",
            "Include upstream changes",
            "Comparison view",
            "Source control navigator",
            "Default branch name",
            "Git",
            "Author Name",
            "Author Email",
            "Prefer to rebase when pulling",
            "Show merge commits in per-file log"
        ]
        .map { NSLocalizedString($0, comment: "") }
    }
}

extension SearchSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        [
            "Ignore Glob Patterns",
            "Ignore Patterns"
        ]
        .map { NSLocalizedString($0, comment: "") }
    }
}

extension LanguageServerSettings: SearchableSettingsPage {
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
}

extension DeveloperSettings: SearchableSettingsPage {
    var searchKeys: [String] {
        [
            "Developer",
            "Language Server Protocol",
            "LSP Binaries",
            "Show Internal Development Inspector"
        ]
        .map { NSLocalizedString($0, comment: "") }
    }
}

extension SettingsPage {
    // swiftlint:disable cyclomatic_complexity
    /// The searchable settings of one page.
    ///
    /// Reads no stored value — every `searchKeys` list is a constant of its section type — so this
    /// is a static function on the page rather than a method on the settings aggregate, which is now
    /// a façade that would need a store just to answer it.
    static func propertiesOf(_ name: SettingsPage.Name) -> [SettingsPage] {
        var settings: [SettingsPage] = []

        switch name {
        case .general:
            GeneralSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .accounts:
            AccountsSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .navigation:
            NavigationSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .theme:
            ThemeSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .textEditing:
            TextEditingSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .terminal:
            TerminalSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .search:
            SearchSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .sourceControl:
            SourceControlSettings().searchKeys.forEach {
                settings.append(.init(name, isSetting: true, settingName: $0))
            }
        case .location:
            LocationsSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .languageServers:
            LanguageServerSettings().searchKeys.forEach {
                settings.append(.init(name, isSetting: true, settingName: $0))
            }
        case .developer:
            DeveloperSettings().searchKeys.forEach { settings.append(.init(name, isSetting: true, settingName: $0)) }
        case .behavior: return [.init(name, settingName: "Error")]
        case .components: return [.init(name, settingName: "Error")]
        case .keybindings: return [.init(name, settingName: "Error")]
        case .advanced: return [.init(name, settingName: "Error")]
        }

        return settings
    }
    // swiftlint:enable cyclomatic_complexity
}
