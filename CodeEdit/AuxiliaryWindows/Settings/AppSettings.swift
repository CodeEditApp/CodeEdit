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
/// The legacy app-side counterpart of ``SettingsValue``. Both now resolve the same way — by
/// observing the injected `PersistentSettingsStore` — so a view can use either without a difference
/// in behaviour. The distinction
/// that remains is what they may name: `SettingsValue` names one section and works inside feature
/// packages, `AppSettings` names the app-wide aggregate and therefore cannot. New code should prefer
/// `SettingsValue`; this wrapper exists so its existing declarations — 47 of them, across 30
/// app-target files — did not all have to move in one change.
///
/// **Only valid inside a `View`.** It used to read a singleton, so it also worked in models and
/// AppKit types; it no longer does, and such a use traps at runtime because no store was injected.
/// Non-view types take a ``SettingsReading``/``SettingsAccessing`` by initializer instead.
///
/// A `Commands` conformer counts as a non-view type here: `.commands { }` is attached beside a
/// scene's content rather than inside it, so the environment is not documented to reach it. See
/// `CodeEditCommands`, which is handed the store by initializer.
@propertyWrapper
struct AppSettings<T>: DynamicProperty where T: Equatable {

    @EnvironmentObject private var store: PersistentSettingsStore

    private let keyPath: WritableKeyPath<SettingsData, T>

    init(_ keyPath: WritableKeyPath<SettingsData, T>) {
        self._store = EnvironmentObject()
        self.keyPath = keyPath
    }

    var wrappedValue: T {
        get { SettingsData(accessor: store)[keyPath: keyPath] }
        nonmutating set {
            // `SettingsData` is a stateless façade, so this "local" mutation writes straight through
            // to the accessor — the section is read, the field replaced, the section written back.
            var settings = SettingsData(accessor: store)
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
