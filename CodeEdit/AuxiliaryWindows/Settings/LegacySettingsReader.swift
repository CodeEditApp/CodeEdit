//
//  LegacySettingsReader.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import CodeEditSettings

/// A `SettingsReading` bridge over the existing `Settings.shared` singleton.
///
/// This is a **stopgap**: it exists only because feature packages have already been cut over to
/// read through `SettingsReading`, but no store backed by real, persisted settings has been built
/// yet to supply the environment. Without this bridge, every `@SettingsValue` read (and every
/// direct `SettingsReading.value(_:)` call) silently falls back to section defaults, ignoring the
/// user's `settings.json` — see the plan's Task 6b for the regression this fixes.
///
/// It is deleted once a later task replaces the singleton-backed store with the real,
/// section-keyed store.
struct LegacySettingsReader: SettingsReading {
    func value<S: SettingsSection>(_ type: S.Type) -> S {
        Self.sections(from: Settings.shared.preferences)[S.settingsKey] as? S ??
            // Explicit fallback, not a silent catch-all: a section with no entry in `sections(from:)`
            // has no field on `SettingsData` to read from, so it answers with defaults until that
            // map is updated (or, more likely, until this bridge is deleted in favor of the real
            // store).
            S()
    }

    /// All eleven `SettingsData` fields, keyed by their section's `settingsKey`.
    private static func sections(from preferences: SettingsData) -> [String: any SettingsSection] {
        [
            GeneralSettings.settingsKey: preferences.general,
            AccountsSettings.settingsKey: preferences.accounts,
            NavigationSettings.settingsKey: preferences.navigation,
            ThemeSettings.settingsKey: preferences.theme,
            TextEditingSettings.settingsKey: preferences.textEditing,
            TerminalSettings.settingsKey: preferences.terminal,
            SourceControlSettings.settingsKey: preferences.sourceControl,
            KeybindingsSettings.settingsKey: preferences.keybindings,
            SearchSettings.settingsKey: preferences.search,
            LanguageServerSettings.settingsKey: preferences.languageServers,
            DeveloperSettings.settingsKey: preferences.developerSettings
        ]
    }
}
