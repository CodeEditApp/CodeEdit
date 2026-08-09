//
//  RecordingSettingsStore.swift
//  CodeEditTests
//
//  Created by Matthijs Eikelenboom on 09/08/2026.
//

import CodeEditSettings

/// A `SettingsAccessing` spy: it stores what is written and reads it back, and remembers every
/// write in order.
///
/// Deliberately *not* a no-op. A discarding double makes a disconnected write path look healthy —
/// which is exactly how the write half shipped untested the first time.
final class RecordingSettingsStore: SettingsAccessing {
    private var sections: [String: any SettingsSection]

    /// Every section handed to ``setValue(_:)``, oldest first.
    private(set) var writes: [any SettingsSection] = []

    init(_ sections: [String: any SettingsSection] = [:]) {
        self.sections = sections
    }

    func value<S: SettingsSection>(_ type: S.Type) -> S {
        sections[S.settingsKey] as? S ?? S()
    }

    func setValue<S: SettingsSection>(_ value: S) {
        sections[S.settingsKey] = value
        writes.append(value)
    }

    /// The most recently written section of the given type, or `nil` if none was ever written.
    func lastWrite<S: SettingsSection>(_ type: S.Type) -> S? {
        writes.reversed().compactMap { $0 as? S }.first
    }
}
