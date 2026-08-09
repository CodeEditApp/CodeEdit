//
//  LegacySettingsStore.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import CodeEditSettings

/// A `SettingsAccessing` bridge over the existing `Settings.shared` singleton.
///
/// This is a **stopgap**: it exists only because feature packages have already been cut over to
/// read and write through `SettingsAccessing`, but no store backed by real, persisted settings has
/// been built yet to supply the environment. Without this bridge, every `@SettingsValue` read (and
/// every direct `SettingsReading.value(_:)` call) silently falls back to section defaults, ignoring
/// the user's `settings.json` — see the plan's Task 6b for the regression this fixes.
///
/// Writes go through `Settings[_:]`, i.e. straight into `Settings.shared.preferences`, so they
/// reach the existing `@Published` → `throttle(for: 2)` → `savePreferences` pipeline. Anything that
/// mutated a copy instead would appear to work and lose the value on relaunch.
///
/// It is deleted once a later task replaces the singleton-backed store with the real,
/// section-keyed store.
struct LegacySettingsStore: SettingsAccessing {
    func value<S: SettingsSection>(_ type: S.Type) -> S {
        Self.accessors[S.settingsKey]?.read(Settings.shared.preferences) as? S ??
            // Explicit fallback, not a silent catch-all: a section with no entry in `accessors`
            // has no field on `SettingsData` to read from, so it answers with defaults until that
            // map is updated (or, more likely, until this bridge is deleted in favor of the real
            // store).
            S()
    }

    func setValue<S: SettingsSection>(_ value: S) {
        // A section absent from `accessors` has nowhere to go on `SettingsData`. Every section
        // declared today is mapped below; a new one that forgets to register here would be
        // discarded, which is why the map is the single source of truth for both directions.
        Self.accessors[S.settingsKey]?.write(value)
    }

    /// A read/write pair for one `SettingsData` field, type-erased over its section type.
    private struct SectionAccessor {
        let read: (SettingsData) -> any SettingsSection
        let write: (any SettingsSection) -> Void

        init<S: SettingsSection>(_ keyPath: WritableKeyPath<SettingsData, S>) {
            read = { $0[keyPath: keyPath] }
            write = { value in
                guard let value = value as? S else { return }
                Settings[keyPath] = value
            }
        }
    }

    /// All eleven `SettingsData` fields, keyed by their section's `settingsKey`.
    private static let accessors: [String: SectionAccessor] = [
        GeneralSettings.settingsKey: SectionAccessor(\.general),
        AccountsSettings.settingsKey: SectionAccessor(\.accounts),
        NavigationSettings.settingsKey: SectionAccessor(\.navigation),
        ThemeSettings.settingsKey: SectionAccessor(\.theme),
        TextEditingSettings.settingsKey: SectionAccessor(\.textEditing),
        TerminalSettings.settingsKey: SectionAccessor(\.terminal),
        SourceControlSettings.settingsKey: SectionAccessor(\.sourceControl),
        KeybindingsSettings.settingsKey: SectionAccessor(\.keybindings),
        SearchSettings.settingsKey: SectionAccessor(\.search),
        LanguageServerSettings.settingsKey: SectionAccessor(\.languageServers),
        DeveloperSettings.settingsKey: SectionAccessor(\.developerSettings)
    ]
}
