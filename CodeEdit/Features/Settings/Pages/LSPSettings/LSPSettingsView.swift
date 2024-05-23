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
                KeyValueTable(
                    items: $lspBinaries,
                    keyColumnName: "Language",
                    valueColumnName: "Language Server Path",
                    newItemInstruction: "Enter new language server path"
                )
            } header: {
                Text("LSP Binaries")
                Text(
                    "Specify the language and the absolute path to the language server binary."
                )
            }
        }
    }
}
