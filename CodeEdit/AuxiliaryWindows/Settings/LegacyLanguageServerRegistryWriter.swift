//
//  LegacyLanguageServerRegistryWriter.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import CELSP
import CodeEditSettings

/// A `LanguageServerRegistryWriting` bridge over the existing `Settings.shared` singleton.
///
/// Mirrors `LegacySettingsReader`'s role, but for the one settings write `CELSP` needs to make
/// (`RegistryManager` persisting install/uninstall/enable changes). It is deleted alongside
/// `LegacySettingsReader` once a later task replaces the singleton-backed store with the real,
/// section-keyed store.
struct LegacyLanguageServerRegistryWriter: LanguageServerRegistryWriting {
    func persistInstalledLanguageServers(_ servers: [String: LanguageServerSettings.Installed]) {
        Settings[\.languageServers.installedLanguageServers] = servers
    }
}
