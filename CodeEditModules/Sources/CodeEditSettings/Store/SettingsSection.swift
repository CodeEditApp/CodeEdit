//
//  SettingsSection.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

/// One independently-stored group of settings, addressed by a stable key.
///
/// The key **is** the top-level key in `settings.json`. Changing it orphans every existing user's
/// values for that section, so treat it as a published contract rather than an implementation
/// detail.
///
/// Deliberately not `Sendable`: `TerminalSettings.Font` carries an `NSFont.Weight`, and requiring
/// `Sendable` here would cascade into `CEEditor`, which is still Swift 5.
public protocol SettingsSection: Codable, Hashable {
    /// The top-level key this section occupies in `settings.json`.
    static var settingsKey: String { get }

    /// A section must be constructible at its defaults, for when the key is absent from the file.
    init()
}
