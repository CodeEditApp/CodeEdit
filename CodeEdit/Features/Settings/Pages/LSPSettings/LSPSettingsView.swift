//
//  DeveloperSettingsView.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/16/24.
//

import SwiftUI

/// A view that implements the Developer settings section
struct DeveloperSettingsView: View {
    @AppSettings(\.developerSettings.lspBinaries)
    var lspBinaries

    var body: some View {
        SettingsForm {
            Section {
                KeyValueTable(items: $lspBinaries)
            } header: {
                Text("LSP Binaries")
                Text(
                    "Add glob patterns to exclude matching files and folders from searches and open quickly. " +
                    "This will inherit glob patterns from the Exclude from Project setting."
                )
            }
        }
    }
}
