//
//  Environment+Theme.swift
//  CodeEditSettings
//
//  Created by Matthijs Eikelenboom on 10.07.26.
//

import SwiftUI

private struct CurrentThemeKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: Theme? = nil
}

private struct CurrentDarkThemeKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: Theme? = nil
}

public extension EnvironmentValues {
    var currentTheme: Theme? {
        get { self[CurrentThemeKey.self] }
        set { self[CurrentThemeKey.self] = newValue }
    }

    /// The user's saved dark-appearance theme, independent of `currentTheme`.
    /// Lets a view force dark colors (e.g. a terminal's "always dark" setting)
    /// without following the editor's active light/dark theme.
    var currentDarkTheme: Theme? {
        get { self[CurrentDarkThemeKey.self] }
        set { self[CurrentDarkThemeKey.self] = newValue }
    }
}
