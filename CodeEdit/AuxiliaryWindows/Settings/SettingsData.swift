//
//  SettingsData.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 01.04.22.
//

import CESourceControl
import CodeEditSettings

/// # SettingsData
///
/// A **façade** over a ``SettingsAccessing``, presenting the app's eleven settings sections as one
/// aggregate so `AppSettings` key paths like `\.theme.matchAppearance` keep working.
///
/// It is no longer `Codable` and holds no state: the store owns persistence, one section at a time,
/// and every property here forwards to it. That is what lets a section be moved into its owning
/// feature package without the aggregate following it — the aggregate is app-side presentation
/// convenience, not the storage format.
///
/// Writes are section-granular by construction: setting `\.theme.matchAppearance` reads the whole
/// `ThemeSettings`, mutates the one field and writes the section back.
struct SettingsData {

    /// The store every property reads and writes through.
    private let accessor: any SettingsAccessing

    init(accessor: any SettingsAccessing) {
        self.accessor = accessor
    }

    /// The general global settings
    var general: GeneralSettings {
        get { accessor.value(GeneralSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// The global settings for accounts
    var accounts: AccountsSettings {
        get { accessor.value(AccountsSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// The global settings for navigation
    var navigation: NavigationSettings {
        get { accessor.value(NavigationSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// The global settings for themes
    var theme: ThemeSettings {
        get { accessor.value(ThemeSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// The global settings for text editing
    var textEditing: TextEditingSettings {
        get { accessor.value(TextEditingSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// The global settings for the terminal emulator
    var terminal: TerminalSettings {
        get { accessor.value(TerminalSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// The global settings for source control
    var sourceControl: SourceControlSettings {
        get { accessor.value(SourceControlSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// The global settings for keybindings
    var keybindings: KeybindingsSettings {
        get { accessor.value(KeybindingsSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// Search Settings
    var search: SearchSettings {
        get { accessor.value(SearchSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// Language Server Settings
    var languageServers: LanguageServerSettings {
        get { accessor.value(LanguageServerSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }

    /// Developer settings for CodeEdit developers
    var developerSettings: DeveloperSettings {
        get { accessor.value(DeveloperSettings.self) }
        nonmutating set { accessor.setValue(newValue) }
    }
}
