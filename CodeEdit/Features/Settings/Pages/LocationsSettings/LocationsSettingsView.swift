//
//  LocationSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

/// A view that implements the `Locations` preference section
struct LocationsSettingsView: View {

    // MARK: View

    var body: some View {
        SettingsForm {
            Section {
                locations
            }
        }
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
        LabeledContent("Settings Location") {
            HStack {
                Text(AppPreferencesModel.shared.baseURL.path)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var themesLocation: some View {
        LabeledContent("Themes Location") {
            HStack {
                Text(ThemeModel.shared.themesURL.path)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                Button {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: ThemeModel.shared.themesURL.path)
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
