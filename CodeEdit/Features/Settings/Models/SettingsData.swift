//
//  Settings.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 01.04.22.
//

import SwiftUI

/// # Settings
///
/// The model structure of settings for `CodeEdit`
///
/// A `JSON` representation is persisted in `~/Library/Application Support/CodeEdit/preference.json`.
/// - Attention: Don't use `UserDefaults` for persisting user accessible settings.
///  If a further setting is needed, extend the struct like ``GeneralSettings``,
///  ``ThemeSettings``,  or ``TerminalSettings`` does.
///
/// - Note: Also make sure to implement the ``init(from:)`` initializer, decoding
///  all properties with
///  [`decodeIfPresent`](https://developer.apple.com/documentation/swift/keyeddecodingcontainer/2921389-decodeifpresent)
///  and providing a default value. Otherwise all settings get overridden.
struct SettingsData: Codable, Hashable {

    /// The general global setting
    var general: GeneralSettings = .init()

    /// The global settings for accounts
    var accounts: AccountsSettings = .init()

    /// The global settings for themes
    var theme: ThemeSettings = .init()

    /// The global settings for the terminal emulator
    var terminal: TerminalSettings = .init()

    /// The global settings for text editing
    var textEditing: TextEditingSettings = .init()

    /// The global settings for source control
    var sourceControl: SourceControlSettings = .init()

    /// The global settings for keybindings
    var keybindings: KeybindingsSettings = .init()

    /// The global settings for locations
    var locations: LocationsSettings = .init()

    /// Default initializer
    init() {}

    /// Explicit decoder init for setting default values when key is not present in `JSON`
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.general = try container.decodeIfPresent(GeneralSettings.self, forKey: .general) ?? .init()
        self.accounts = try container.decodeIfPresent(AccountsSettings.self, forKey: .accounts) ?? .init()
        self.theme = try container.decodeIfPresent(ThemeSettings.self, forKey: .theme) ?? .init()
        self.terminal = try container.decodeIfPresent(TerminalSettings.self, forKey: .terminal) ?? .init()
        self.textEditing = try container.decodeIfPresent(TextEditingSettings.self, forKey: .textEditing) ?? .init()
        self.sourceControl = try container.decodeIfPresent(
            SourceControlSettings.self,
            forKey: .sourceControl
        ) ?? .init()
        self.keybindings = try container.decodeIfPresent(
            KeybindingsSettings.self,
            forKey: .keybindings
        ) ?? .init()
        self.locations = try container.decodeIfPresent(
            LocationsSettings.self,
            forKey: .locations
        ) ?? .init()
    }

    func propertiesOf(_ value: Any) -> [SettingsPageSetting] {
        var properties: [SettingsPageSetting] = []
        let mirror: Mirror = Mirror(reflecting: value)
        let translator: ModelNameToSettingName = .init()

        guard let style = mirror.displayStyle, style == .struct else {
            return [SettingsPageSetting(nameString: "Error")]
        }

        for (possibleLabel, _) in mirror.children {
            guard let label = possibleLabel else {
                continue
            }

            properties.append(SettingsPageSetting(nameString: translator.translate(label)))
        }

        return properties
    }
}
