//
//  AppSettings.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 12/04/2023.
//

import Foundation
import SwiftUI

@propertyWrapper
struct AppSettings: DynamicProperty {
    @ObservedObject
    private var prefs: Settings

    init(_ prefs: Settings = .shared) {
        self.prefs = prefs
    }

    var wrappedValue: SettingsData {
        get {
            prefs.preferences
        }
        nonmutating set {
            prefs.preferences = newValue
        }
    }

    var projectedValue: Binding<SettingsData> {
        $prefs.preferences
    }
}
