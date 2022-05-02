//
//  LocationsPreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 03.04.22.
//

import SwiftUI
import Preferences

/// A view that implements the `Locations` preference section
public struct LocationsPreferencesView: View {

    public init() {}

    public var body: some View {
        PreferencesContent {
            PreferencesSection("Preferences Location") {
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

private struct LocationsPreferences_Previews: PreviewProvider {
    public static var previews: some View {
        LocationsPreferencesView()
    }
}
