//
//  SettingsInjector.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 28/04/2023.
//

import SwiftUI
import CodeEditSettings

struct SettingsInjector<Content: View>: View {

    @ObservedObject var settings = Settings.shared

    @ViewBuilder var content: Content

    var body: some View {
        content
            .environment(\.settings, settings.preferences)
            // `@ObservedObject` above means this recomputes on every `Settings.shared` change,
            // so wrapped trees using `@SettingsValue`/`SettingsReading` re-render on settings
            // changes too — a bare one-shot `.environment(\.settingsReader, LegacySettingsReader())`
            // would not.
            .environment(\.settingsReader, LegacySettingsReader())
    }
}
