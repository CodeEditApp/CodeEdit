//
//  WorkspaceSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 29/3/24.
//

import Foundation
import SwiftUI

@propertyWrapper
struct WorkspaceSettings<T>: DynamicProperty where T: Equatable {

    var workspaceSettings: Environment<T>

    let keyPath: WritableKeyPath<CEWorkspaceSettingsData, T>

    init(_ keyPath: WritableKeyPath<CEWorkspaceSettingsData, T>) {
        self.keyPath = keyPath
        let settingsKeyPath = (\EnvironmentValues.workspaceSettings).appending(path: keyPath)
        self.workspaceSettings = Environment(settingsKeyPath)
    }

    var wrappedValue: T {
        get {
            CEWorkspaceSettings.shared.preferences[keyPath: keyPath]
        }
        nonmutating set {
            CEWorkspaceSettings.shared.preferences[keyPath: keyPath] = newValue
        }
    }

    var projectedValue: Binding<T> {
        Binding {
            CEWorkspaceSettings.shared.preferences[keyPath: keyPath]
        } set: {
            CEWorkspaceSettings.shared.preferences[keyPath: keyPath] = $0
        }
    }
}

struct CEWorkspaceeSettingsDataEnvironmentKey: EnvironmentKey {
    static var defaultValue: SettingsData = .init()
}

extension EnvironmentValues {
    var workspaceSettings: CEWorkspaceeSettingsDataEnvironmentKey.Value {
        get { self[CEWorkspaceeSettingsDataEnvironmentKey.self] }
        set { self[CEWorkspaceeSettingsDataEnvironmentKey.self] = newValue }
    }
}

