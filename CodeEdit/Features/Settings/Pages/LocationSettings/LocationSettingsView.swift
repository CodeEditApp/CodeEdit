//
//  LocationSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

/// A view that implements the `Locations` preference section
struct LocationSettingsView: View {

    // MARK: View

    var body: some View {
        Form {
            Section {
                locations
            }
        }
        .formStyle(.grouped)
    }
}

private extension LocationSettingsView {

    // MARK: Sections

    @ViewBuilder
    private var locations: some View {
        preferencesLocation
        themesLocation
    }

    // MARK: Preference Views

    @ViewBuilder
    private var preferencesLocation: some View {
        Group {
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
    }

    private var themesLocation: some View {
        Group {
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
