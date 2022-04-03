//
//  PreferencesTextEditingView.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import FontPicker

public struct PreferencesTextEditingView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    private var numberFormat: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        formatter.minimum = 1
        formatter.maximum = 8

        return formatter
    }

    public var body: some View {
        PreferencesContent {
            PreferencesSection("Default Tab Width") {
                HStack(spacing: 5) {
                    TextField("", value: $prefs.preferences.textEditing.defaultTabWidth, formatter: numberFormat)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 40)
                    Stepper("Default Tab Width:",
                            value: $prefs.preferences.textEditing.defaultTabWidth,
                            in: 1...8)
                    Text("spaces")
                }
            }
            PreferencesSection("Font") {
                fontSelector
            }
        }
    }

    @ViewBuilder
    private var fontSelector: some View {
        Picker("Font:", selection: $prefs.preferences.textEditing.font.customFont) {
            Text("System Font")
                .tag(false)
            Text("Custom")
                .tag(true)
        }
        .fixedSize()
        if prefs.preferences.textEditing.font.customFont {
            FontPicker(
                "\(prefs.preferences.textEditing.font.name) \(prefs.preferences.textEditing.font.size)",
                name: $prefs.preferences.textEditing.font.name, size: $prefs.preferences.textEditing.font.size
            )
        }
    }
}
