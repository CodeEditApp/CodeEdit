//
//  SettingsValue.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 09/08/26.
//

import SwiftUI

/// Read access to settings, one section at a time.
///
/// Feature packages depend on this rather than on the concrete store, so they never name the
/// app-wide aggregate and never reach a singleton.
///
/// Deliberately neither `Sendable` nor `@MainActor`: conforming types include a store class whose
/// methods cannot be actor-isolated without breaking this conformance, and `EnvironmentKey`
/// requires a nonisolated static default.
public protocol SettingsReading {
    /// The current value of `type`, or its defaults if the section is absent.
    func value<S: SettingsSection>(_ type: S.Type) -> S
}

/// A reader that always answers with defaults. The environment's fallback, so a preview with no
/// store configured still renders.
public struct DefaultSettingsReader: SettingsReading {
    public init() {}

    public func value<S: SettingsSection>(_ type: S.Type) -> S {
        S()
    }
}

/// A fixed reader for tests and SwiftUI previews.
public struct SnapshotSettingsReader: SettingsReading {
    private let sections: [String: any SettingsSection]

    public init(_ sections: [String: any SettingsSection]) {
        self.sections = sections
    }

    public func value<S: SettingsSection>(_ type: S.Type) -> S {
        sections[S.settingsKey] as? S ?? S()
    }
}

public struct SettingsReaderKey: EnvironmentKey {
    /// Defaults are a legitimate value here — a preview with no store configured should render.
    nonisolated(unsafe) public static let defaultValue: SettingsReading = DefaultSettingsReader()
}

public extension EnvironmentValues {
    /// The settings reader for the current view tree.
    var settingsReader: SettingsReading {
        get { self[SettingsReaderKey.self] }
        set { self[SettingsReaderKey.self] = newValue }
    }
}

/// Reads one property of one settings section inside a SwiftUI view.
///
/// ```swift
/// @SettingsValue(TerminalSettings.self, \.cursorBlink) private var cursorBlink
/// ```
///
/// Only valid inside a `View`. AppKit types must be handed the value by their
/// `NSViewRepresentable` instead — read at the SwiftUI boundary, pass by value inward.
@propertyWrapper
public struct SettingsValue<S: SettingsSection, Value>: DynamicProperty {
    @Environment(\.settingsReader)
    private var reader

    private let keyPath: KeyPath<S, Value>

    public init(_ section: S.Type, _ keyPath: KeyPath<S, Value>) {
        self.keyPath = keyPath
    }

    public var wrappedValue: Value {
        reader.value(S.self)[keyPath: keyPath]
    }
}
