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

public extension EnvironmentValues {
    var currentTheme: Theme? {
        get { self[CurrentThemeKey.self] }
        set { self[CurrentThemeKey.self] = newValue }
    }
}
