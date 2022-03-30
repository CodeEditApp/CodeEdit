//
//  AppPreferencesView.swift
//  
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import Preferences

public struct AppPreferencesView: View {

    public init() {}

    public var body: some View {
        Preferences.Container(contentWidth: 844) {
            Preferences.Section(title: "Test") {
                Text("Some Test")
            }
        }
    }
}
