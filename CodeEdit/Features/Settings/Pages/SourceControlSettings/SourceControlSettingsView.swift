//
//  SourceControlSettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlSettingsView: View {
    var body: some View {
        SettingsForm {
            SourceControlGeneralView()
            SourceControlGitView()
        }
    }
}
