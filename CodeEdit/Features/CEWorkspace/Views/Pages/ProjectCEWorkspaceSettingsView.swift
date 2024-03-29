//
//  GeneralCEWorkspaceSettingsView.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI

/// A view that implements the `Project` worksppace settings page
struct ProjectCEWorkspaceSettingsView: View {
    @AppSettings(\.sourceControl.git)
    var settings

    var body: some View {
        SettingsForm {
            Section {
                projectName
            }
        }
    }
}

/// The extension of the view with all the preferences
private extension ProjectCEWorkspaceSettingsView {
    private var projectName: some View {
        TextField(text: $settings.projectedValue) {
            Text("Name")
        }
    }
}

