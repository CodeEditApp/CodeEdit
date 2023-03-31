//
//  KeybindingsSettingsView.swift
//  
//
//  Created by Alex on 19.05.2022.
//

import SwiftUI

struct KeybindingsSettingsView: View {

    // MARK: - View

    var body: some View {
        mainSection
    }
}

private extension KeybindingsSettingsView {

    // MARK: - Sections

    private var mainSection: some View {
        SettingsContent {
            implementationNeededText
        }
    }

    // MARK: - Preference Views

    private var implementationNeededText: some View {
        Text("Implementation needed")
    }
}
