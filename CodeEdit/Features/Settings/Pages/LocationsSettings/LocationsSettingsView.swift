//
//  LocationSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

/// A view that implements the `Locations` preference section
struct LocationsSettingsView: View {
    @AppSettings(\.locations) var locations

    var body: some View {
        SettingsForm {
            Section {
                applicationSupportLocation
                settingsLocation
                themesLocation
                extensionsLocation
            }
        }
    }
}

private extension LocationsSettingsView {
    @ViewBuilder private var applicationSupportLocation: some View {
        ExternalLink(destination: Settings.shared.baseURL) {
            Text("Application Support")
            Text(Settings.shared.baseURL.path)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    private var settingsLocation: some View {
        ExternalLink(destination: locations.settingsURL) {
            Text("Settings")
            Text(locations.settingsURL.path)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    private var themesLocation: some View {
        ExternalLink(destination: locations.themesURL) {
            Text("Themes")
            Text(locations.themesURL.path)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    private var extensionsLocation: some View {
        ExternalLink(destination: locations.extensionsURL) {
            Text("Extensions")
            Text(locations.extensionsURL.path)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
}
