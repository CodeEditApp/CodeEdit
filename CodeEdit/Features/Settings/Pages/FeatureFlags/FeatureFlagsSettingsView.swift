//
//  FeatureFlagsSettingsView.swift
//  CodeEdit
//
//  Created by Wouter Hennen on 17/06/2023.
//

import SwiftUI

struct FeatureFlagsSettingsView: View {

    @AppSettings(\.featureFlags.useNewWindowingSystem) var useNewWindowingSystem

    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Toggle("New Windowing System", isOn: $useNewWindowingSystem)
                Text(
                    """
                    Active workspaces must be reopened in order to take effect.
                    Inspector only works on macOS Sonoma.
                    """
                )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
