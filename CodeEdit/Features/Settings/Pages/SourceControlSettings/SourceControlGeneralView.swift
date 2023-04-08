//
//  SourceControlGeneralView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlGeneralView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var text: String = "main"

    var body: some View {
        SettingsForm {
            Section {
                enableSourceControl
                refreshLocalStatusAuto
                fetchRefreshStatusAuto
                addRemoveFilesAuto
                selectFilesToCommitAuto
            }
            Section {
                showSourceControlChanges
                includeUpstreamChanges
            }
            Section {
                comparisonView
                sourceControlNavigator
                defaultBranchName
            }
        }
    }
}

private extension SourceControlGeneralView {
    private var enableSourceControl: some View {
        Toggle(
            "Enable source control",
            isOn: $prefs.preferences.sourceControl.general.enableSourceControl
        )
    }

    private var refreshLocalStatusAuto: some View {
        Toggle(
            "Refresh local status automatically",
            isOn: $prefs.preferences.sourceControl.general.refreshStatusLocally
        )
    }

    private var fetchRefreshStatusAuto: some View {
        Toggle(
            "Fetch and refresh server status automatically",
            isOn: $prefs.preferences.sourceControl.general.fetchRefreshServerStatus
        )
    }

    private var addRemoveFilesAuto: some View {
        Toggle(
            "Add and remove files automatically",
            isOn: $prefs.preferences.sourceControl.general.addRemoveAutomatically
        )
    }

    private var selectFilesToCommitAuto: some View {
        Toggle(
            "Select files to commit automatically",
            isOn: $prefs.preferences.sourceControl.general.selectFilesToCommit
        )
    }

    private var showSourceControlChanges: some View {
        Toggle(
            "Show source control changes",
            isOn: $prefs.preferences.sourceControl.general.showSourceControlChanges
        )
    }

    private var includeUpstreamChanges: some View {
        Toggle(
            "Include upstream changes",
            isOn: $prefs.preferences.sourceControl.general.includeUpstreamChanges
        )
    }

    private var comparisonView: some View {
        Picker(
            "Comparison view",
            selection: $prefs.preferences.sourceControl.general.revisionComparisonLayout
        ) {
            Text("Local Revision on Left Side")
                .tag(AppPreferences.RevisionComparisonLayout.localLeft)
            Text("Local Revision on Right Side")
                .tag(AppPreferences.RevisionComparisonLayout.localRight)
        }
    }

    private var sourceControlNavigator: some View {
        Picker(
            "Source control navigator",
            selection: $prefs.preferences.sourceControl.general.controlNavigatorOrder
        ) {
            Text("Sort by Name")
                .tag(AppPreferences.ControlNavigatorOrder.sortByName)
            Text("Sort by Date")
                .tag(AppPreferences.ControlNavigatorOrder.sortByDate)
        }
    }

    private var defaultBranchName: some View {
        TextField(text: $text) {
            Text("Default branch name")
            Text("Cannot contain spaces, backslashes, or other symbols")
        }
    }
}
