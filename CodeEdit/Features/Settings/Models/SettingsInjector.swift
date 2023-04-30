//
//  SettingsInjector.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 28/04/2023.
//

import SwiftUI

struct SettingsInjector<Content: View>: View {

    @ObservedObject var settings = Settings.shared

    @ViewBuilder var content: Content

    var body: some View {
        content
            .environment(\.settings, settings.preferences)
    }
}
