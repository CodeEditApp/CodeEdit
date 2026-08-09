//
//  SettingsAccessing.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

/// Read *and* write access to settings, one section at a time.
///
/// The write half of the settings seam. It extends ``SettingsReading`` rather than standing beside
/// it as a separate `SettingsWriting`, because a read-write consumer — most importantly
/// ``SettingsValue``'s `projectedValue`, which must produce a `Binding` — needs both halves from a
/// *single* value. Two protocols would mean two environment keys, and a view could then be handed a
/// live reader next to a defaulted writer: reads would look correct while writes silently vanished.
/// One protocol makes that state unrepresentable.
///
/// Consumers that only read should keep depending on ``SettingsReading``; every `SettingsAccessing`
/// satisfies it, so narrowing costs nothing.
///
/// Deliberately neither `Sendable` nor `@MainActor`, for the same reasons documented on
/// ``SettingsReading``.
public protocol SettingsAccessing: SettingsReading {
    /// Stores `value`, replacing the whole section it belongs to.
    ///
    /// Section-granular by design: a caller changing one field reads the section, mutates it and
    /// writes it back, so it never has to name the app-wide settings aggregate.
    func setValue<S: SettingsSection>(_ value: S)
}
