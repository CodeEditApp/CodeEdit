//
//  KeybindingsPreferencesView.swift
//  
//
//  Created by Alex on 19.05.2022.
//

import SwiftUI

struct KeybindingsPreferencesView: View {

    // MARK: - View

    var body: some View {
        mainSection
    }
}

private extension KeybindingsPreferencesView {

    // MARK: - Sections

    private var mainSection: some View {
        PreferencesContent {
            implementationNeededText
        }
    }

    // MARK: - Preference Views

    private var implementationNeededText: some View {
        Text("Implementation needed")
    }
}
