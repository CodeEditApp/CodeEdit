//
//  SourceControlGeneralView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlGeneralView: View {
    @AppSettings var settings

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
            isOn: $settings.sourceControl.general.enableSourceControl
        )
    }

    private var refreshLocalStatusAuto: some View {
        Toggle(
            "Refresh local status automatically",
            isOn: $settings.sourceControl.general.refreshStatusLocally
        )
    }

    private var fetchRefreshStatusAuto: some View {
        Toggle(
            "Fetch and refresh server status automatically",
            isOn: $settings.sourceControl.general.fetchRefreshServerStatus
        )
    }

    private var addRemoveFilesAuto: some View {
        Toggle(
            "Add and remove files automatically",
            isOn: $settings.sourceControl.general.addRemoveAutomatically
        )
    }

    private var selectFilesToCommitAuto: some View {
        Toggle(
            "Select files to commit automatically",
            isOn: $settings.sourceControl.general.selectFilesToCommit
        )
    }

    private var showSourceControlChanges: some View {
        Toggle(
            "Show source control changes",
            isOn: $settings.sourceControl.general.showSourceControlChanges
        )
    }

    private var includeUpstreamChanges: some View {
        Toggle(
            "Include upstream changes",
            isOn: $settings.sourceControl.general.includeUpstreamChanges
        )
    }

    private var comparisonView: some View {
        Picker(
            "Comparison view",
            selection: $settings.sourceControl.general.revisionComparisonLayout
        ) {
            Text("Local Revision on Left Side")
                .tag(SettingsData.RevisionComparisonLayout.localLeft)
            Text("Local Revision on Right Side")
                .tag(SettingsData.RevisionComparisonLayout.localRight)
        }
    }

    private var sourceControlNavigator: some View {
        Picker(
            "Source control navigator",
            selection: $settings.sourceControl.general.controlNavigatorOrder
        ) {
            Text("Sort by Name")
                .tag(SettingsData.ControlNavigatorOrder.sortByName)
            Text("Sort by Date")
                .tag(SettingsData.ControlNavigatorOrder.sortByDate)
        }
    }

    private var defaultBranchName: some View {
        TextField(text: $text) {
            Text("Default branch name")
            Text("Cannot contain spaces, backslashes, or other symbols")
        }
    }
}
