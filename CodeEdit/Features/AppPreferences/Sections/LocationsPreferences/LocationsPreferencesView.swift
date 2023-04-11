//
//  LocationsPreferencesView.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 03.04.22.
//

import SwiftUI
import Preferences

/// A view that implements the `Locations` preference section
struct LocationsPreferencesView: View {
    var body: some View {
        PreferencesContent {
            PreferencesSection("Preferences Location") {
                HStack {
                    Text(SettingsModel.shared.baseURL.path)
                        .foregroundColor(.secondary)
                    Button {
                        NSWorkspace.shared.selectFile(
                            nil,
                            inFileViewerRootedAtPath: SettingsModel.shared.baseURL.path
                        )
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
            }
            PreferencesSection("Themes Location") {
                HStack {
                    Text(ThemeModel.shared.themesURL.path)
                        .foregroundColor(.secondary)
                    Button {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: ThemeModel.shared.themesURL.path)
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}
