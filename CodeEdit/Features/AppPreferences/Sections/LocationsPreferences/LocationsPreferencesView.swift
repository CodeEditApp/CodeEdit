//
//  LocationsPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 03.04.22.
//

import SwiftUI
import Preferences

/// A view that implements the `Locations` preference section
struct LocationsPreferencesView: View {
    // MARK: - View
    var body: some View {
        PreferencesContent {
            preferencesLocationSection
            themesLocationSection
        }
    }
}

private extension LocationsPreferencesView {
    // MARK: - Sections
    private var preferencesLocationSection: some View {
        PreferencesSection("Preferences Location") {
            preferencesLocation
        }
    }

    private var themesLocationSection: some View {
        PreferencesSection("Themes Location") {
            themesLocation
        }
    }

    // MARK: - Preference Views

    @ViewBuilder
    private var preferencesLocation: some View {
        HStack {
            Text(AppPreferencesModel.shared.baseURL.path)
                .foregroundColor(.secondary)
            Button {
                NSWorkspace.shared.selectFile(
                    nil,
                    inFileViewerRootedAtPath: AppPreferencesModel.shared.baseURL.path
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
