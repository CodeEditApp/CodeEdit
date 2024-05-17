//
//  LSPSettingsView.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/16/24.
//

import SwiftUI

/// A view that implements the `LSP Settings` settings section
struct LSPSettingsView: View {
    @AppSettings(\.lspSettings.lspBinaries)
    var lspBinaries

    var body: some View {
        SettingsForm {
            KeyValueTable(items: $lspBinaries)
        }
    }
}
