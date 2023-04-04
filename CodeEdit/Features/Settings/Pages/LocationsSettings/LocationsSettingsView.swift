//
//  LocationSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

/// A view that implements the `Locations` settings page
struct LocationsSettingsView: View {
    var body: some View {
        Form {
            Section {
                locations
            }
        }
        .formStyle(.grouped)
    }
}

private extension LocationsSettingsView {
    // MARK: Sections

    @ViewBuilder
    private var locations: some View {
        settingsLocation
        themesLocation
    }

    // MARK: Preference Views

    @ViewBuilder
    private var settingsLocation: some View {
        Group {
            HStack {
                Text("Settings Location: \(AppPreferencesModel.shared.baseURL.path)")
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
    }

    private var themesLocation: some View {
        Group {
            HStack {
                Text("Themes Location: \(ThemeModel.shared.themesURL.path)")
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
