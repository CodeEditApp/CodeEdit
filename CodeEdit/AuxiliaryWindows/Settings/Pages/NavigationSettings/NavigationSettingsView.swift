//
//  NavigationSettingsView.swift
//  CodeEdit
//
//  Created by Austin Condiff on 3/4/24.
//

import SwiftUI
import CodeEditSettings

struct NavigationSettingsView: View {
    @AppSettings(\.navigation)
    var settings

    var body: some View {
        SettingsForm {
            Section {
                navigationStyle
            }
        }
    }
}

private extension NavigationSettingsView {
    private var navigationStyle: some View {
        Picker("Navigation Style", selection: $settings.navigationStyle) {
            Text("Open in Tabs")
                .tag(NavigationSettings.NavigationStyle.openInTabs)
            Text("Open in Place")
                .tag(NavigationSettings.NavigationStyle.openInPlace)
        }
    }
}
