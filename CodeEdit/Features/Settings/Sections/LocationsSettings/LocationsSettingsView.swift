//
//  LocationsSettingsView.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 03.04.22.
//

import SwiftUI
import Settings

/// A view that implements the `Locations` preference section
struct LocationsSettingsView: View {

    // MARK: - View

    var body: some View {
        SettingsContent {
            settingsLocationSection
            themesLocationSection
        }
    }
}

private extension LocationsSettingsView {

    // MARK: - Sections

    private var settingsLocationSection: some View {
        SettingsSection("Settings Location") {
            settingsLocation
        }
    }

    private var themesLocationSection: some View {
        SettingsSection("Themes Location") {
            themesLocation
        }
    }

    // MARK: - Preference Views

    @ViewBuilder
    private var settingsLocation: some View {
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

    private var themesLocation: some View {
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
