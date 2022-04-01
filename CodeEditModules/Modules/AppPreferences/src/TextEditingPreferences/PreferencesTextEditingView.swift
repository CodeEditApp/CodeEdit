//
//  PreferencesTextEditingView.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

public struct PreferencesTextEditingView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    public init() {}

    public var body: some View {
        Form {
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
}
