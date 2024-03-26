//
//  AppSettings.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 12/04/2023.
//

import Foundation
import SwiftUI

@propertyWrapper
struct AppSettings<T>: DynamicProperty where T: Equatable {

    var settings: Environment<T>

    let keyPath: WritableKeyPath<SettingsData, T>

    init(_ keyPath: WritableKeyPath<SettingsData, T>) {
        self.keyPath = keyPath
        let settingsKeyPath = (\EnvironmentValues.settings).appending(path: keyPath)
        self.settings = Environment(settingsKeyPath)
    }

    var wrappedValue: T {
        get {
            Settings.shared.preferences[keyPath: keyPath]
        }
        nonmutating set {
            Settings.shared.preferences[keyPath: keyPath] = newValue
        }
    }

    var projectedValue: Binding<T> {
        Binding {
            Settings.shared.preferences[keyPath: keyPath]
        } set: {
            Settings.shared.preferences[keyPath: keyPath] = $0
        }
    }
}

struct SettingsDataEnvironmentKey: EnvironmentKey {
    static var defaultValue: SettingsData = .init()
}

extension EnvironmentValues {
    var settings: SettingsDataEnvironmentKey.Value {
        get { self[SettingsDataEnvironmentKey.self] }
        set { self[SettingsDataEnvironmentKey.self] = newValue }
    }
}
