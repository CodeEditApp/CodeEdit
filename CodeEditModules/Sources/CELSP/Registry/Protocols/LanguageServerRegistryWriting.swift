//
//  LanguageServerRegistryWriting.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

import CodeEditSettings

/// Persists `RegistryManager`'s installed-language-server registry back to settings.
///
/// `SettingsReading` (the settings-ownership refactor's read seam) has no write half, and
/// `RegistryManager` is the one place in the app that mutates this particular registry
/// (install/uninstall/enable-disable). Rather than reintroduce `Settings.shared` into `CELSP` or
/// grow `SettingsReading` into a general read/write interface for one caller, this protocol asks
/// for exactly the capability `RegistryManager` needs. It is a stopgap, like `LegacySettingsReader`
/// — both are expected to fold into the real, section-keyed settings store once that lands.
public protocol LanguageServerRegistryWriting {
    /// Persists the full registry, replacing whatever was previously stored.
    func persistInstalledLanguageServers(_ servers: [String: LanguageServerSettings.Installed])
}

/// A writer that discards every write. For tests and previews where persistence is irrelevant.
public final class NoOpLanguageServerRegistryWriting: LanguageServerRegistryWriting {
    /// Creates a writer that discards every write.
    public init() {}

    /// Discards the registry instead of persisting it.
    public func persistInstalledLanguageServers(_ servers: [String: LanguageServerSettings.Installed]) {}
}
