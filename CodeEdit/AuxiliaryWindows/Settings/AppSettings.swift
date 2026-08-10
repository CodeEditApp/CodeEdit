//
//  AppSettings.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 12/04/2023.
//

import SwiftUI
import CodeEditSettings

/// Reads and writes one setting inside a SwiftUI view, addressed through the app-wide
/// ``SettingsData`` aggregate.
///
/// The legacy app-side counterpart of ``SettingsValue``. Both now resolve the same way — through
/// ``EnvironmentValues/settingsAccessor`` for the value and ``EnvironmentValues/settingsRevision``
/// for invalidation — so a view can use either without a difference in behaviour. The distinction
/// that remains is what they may name: `SettingsValue` names one section and works inside feature
/// packages, `AppSettings` names the app-wide aggregate and therefore cannot. New code should prefer
/// `SettingsValue`; this wrapper exists so its existing declarations — 47 of them, across 30
/// app-target files — did not all have to move in one change.
///
/// **Only valid inside a `View`.** It used to read a singleton, so it also worked in models and
/// AppKit types; it no longer does, and such a use resolves to `DefaultSettingsReader`, which traps
/// in debug. Non-view types take a ``SettingsReading``/``SettingsAccessing`` by initializer instead.
///
/// A `Commands` conformer counts as a non-view type here: `.commands { }` is attached beside a
/// scene's content rather than inside it, so the environment is not documented to reach it. See
/// `CodeEditCommands`, which is handed the store by initializer.
@propertyWrapper
struct AppSettings<T>: DynamicProperty where T: Equatable {

    @Environment(\.settingsAccessor)
    private var accessor

    /// Not a source of data — a source of *invalidation*. See ``EnvironmentValues/settingsRevision``.
    @Environment(\.settingsRevision)
    private var revision

    private let keyPath: WritableKeyPath<SettingsData, T>

    init(_ keyPath: WritableKeyPath<SettingsData, T>) {
        self.keyPath = keyPath
    }

    var wrappedValue: T {
        get {
            // Read, not merely declared: an unread `@Environment` is a dependency SwiftUI does not
            // document itself as tracking, and being tracked is this property's entire purpose.
            _ = revision
            return SettingsData(accessor: accessor)[keyPath: keyPath]
        }
        nonmutating set {
            // `SettingsData` is a stateless façade, so this "local" mutation writes straight through
            // to the accessor — the section is read, the field replaced, the section written back.
            var settings = SettingsData(accessor: accessor)
            settings[keyPath: keyPath] = newValue
        }
    }

    var projectedValue: Binding<T> {
        Binding {
            wrappedValue
        } set: {
            wrappedValue = $0
        }
    }
}
