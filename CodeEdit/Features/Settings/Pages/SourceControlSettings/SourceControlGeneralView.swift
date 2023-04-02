//
//  SourceControlGeneralView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlGeneralView: View {

    // MARK: - View

    var body: some View {
        Form {
            Section {
                topSection
            }
            Section {
                middleSection
            }
            Section {
                bottomSection
            }
        }
        .formStyle(.grouped)
    }

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var text: String = "main"
}

private extension SourceControlGeneralView {

    // MARK: - Sections

    @ViewBuilder
    private var topSection: some View {
        enableSourceControl
        refreshLocalStatusAuto
        fetchRefreshStatusAuto
        addRemoveFilesAuto
        selectFilesToCommitAuto
    }

    @ViewBuilder
    private var middleSection: some View {
        showSourceControlChanges
        includeUpstreamChanges
    }

    @ViewBuilder
    private var bottomSection: some View {
        comparisonView
        sourceControlNavigator
        defaultBranchName
    }

    // MARK: - Preference Views

    private var enableSourceControl: some View {
        Toggle(
            "Enable Source Control",
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

    @ViewBuilder
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
            "Show Source Control changes",
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
            "Comparison View",
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
            "Source Control Navigator",
            selection: $prefs.preferences.sourceControl.general.controlNavigatorOrder
        ) {
            Text("Sort by Name")
                .tag(AppPreferences.ControlNavigatorOrder.sortByName)
            Text("Sort by Date")
                .tag(AppPreferences.ControlNavigatorOrder.sortByDate)
        }
    }

    @ViewBuilder
    private var defaultBranchName: some View {
        TextField("Default Branch name", text: $text)
        Text("Branch names cannot contain spaces, backslashes, or other symbols")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
    }
}
