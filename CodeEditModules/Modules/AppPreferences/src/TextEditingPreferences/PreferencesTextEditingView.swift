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

    public var body: some View {
        Form {
            fontSelector
            HStack {
                Stepper("Default Tab Width:",
                        value: $prefs.preferences.textEditing.defaultTabWidth,
                        in: 2...8)
                Text(String(prefs.preferences.textEditing.defaultTabWidth))
            }
        }
        .frame(width: 844)
        .padding(30)
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
