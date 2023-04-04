//
//  SourceControlSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

/// A view that implements the `Source Control` settings page
struct SourceControlSettingsView: View {
    var body: some View {
        Form {
            SourceControlGeneralView()
            SourceControlGitView()
        }
        .formStyle(.grouped)
    }
}
