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
            .environment(\.settingsAccessor, LegacySettingsStore())
            // The seam's invalidation signal. Rewriting the accessor above is *not* enough:
            // `LegacySettingsStore` is a stateless struct behind an existential, so whether SwiftUI
            // treats the rewrite as a change is unspecified — and `.appServices(_:)`, applied
            // closer to the leaf in `CodeEditSplitViewController`, overwrites it with a
            // process-lifetime instance anyway. `settingsRevision` is `Equatable` and lives in its
            // own key, so neither of those can defeat it.
            .environment(\.settingsRevision, settings.revision)
    }
}
