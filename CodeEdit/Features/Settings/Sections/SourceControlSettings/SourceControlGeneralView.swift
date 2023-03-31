//
//  SourceControlGeneralView.swift
//  CodeEditModules/Settings
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGeneralView: View {

    // MARK: - View

    var body: some View {
        VStack {
            sourceControlSection
            textEditingSection
            reportingSection
            comparisonViewSection
            sourceControlNavigator
            defaultBranchNameSection
        }
            .frame(width: 715)
            .background(EffectView(.contentBackground))
    }

    private let inputWidth: Double = 200

    @StateObject
    private var prefs: SettingsModel = .shared

    @State
    var isChecked: Bool

    @State
    var branchName: String
}

private extension SourceControlGeneralView {

    // MARK: - Sections

    private var sourceControlSection: some View {
        SettingsSection("Source Control", hideLabels: false) {
            enableSourceControl

            VStack(alignment: .leading) {
                refreshLocalStatusAuto
                fetchRefreshStatusAuto
                addRemoveFilesAuto
                selectFilesToCommitAuto
            }
            .padding(.leading, 20)
        }
    }

    private var textEditingSection: some View {
        SettingsSection("Text Editing", hideLabels: false) {
            showSourceControlChanges
            includeUpstreamChanges
        }
    }

    private var reportingSection: some View {
        SettingsSection("Reporting", hideLabels: false) {
            openCreatedIssueInBrowser
        }
    }

    private var comparisonViewSection: some View {
        SettingsSection("Comparison View", hideLabels: true) {
            comparisonView
        }
    }

    private var sourceControlNavigatorSection: some View {
        SettingsSection("Source Control Navigator", hideLabels: true) {
            sourceControlNavigator
        }
    }

    private var defaultBranchNameSection: some View {
        SettingsSection("Default Branch Name", hideLabels: false) {
            defaultBranchName
        }
    }

    // MARK: - Preference Views

    private var enableSourceControl: some View {
        Toggle(
            "Enable Source Control",
            isOn: $prefs.settings.sourceControl.general.enableSourceControl
        )
            .toggleStyle(.checkbox)
    }

    private var refreshLocalStatusAuto: some View {
        Toggle(
            "Refresh local status automatically",
            isOn: $prefs.settings.sourceControl.general.refreshStatusLocally
        )
            .toggleStyle(.checkbox)
    }

    private var fetchRefreshStatusAuto: some View {
        Toggle(
            "Fetch and refresh server status automatically",
            isOn: $prefs.settings.sourceControl.general.fetchRefreshServerStatus
        )
            .toggleStyle(.checkbox)
    }

    private var addRemoveFilesAuto: some View {
        Toggle(
            "Add and remove files automatically",
            isOn: $prefs.settings.sourceControl.general.addRemoveAutomatically
        )
        .toggleStyle(.checkbox)
    }

    private var selectFilesToCommitAuto: some View {
        Toggle(
            "Select files to commit automatically",
            isOn: $prefs.settings.sourceControl.general.selectFilesToCommit
        )
        .toggleStyle(.checkbox)
    }

    private var showSourceControlChanges: some View {
        Toggle(
            "Show Source Control changes",
            isOn: $prefs.settings.sourceControl.general.showSourceControlChanges
        )
        .toggleStyle(.checkbox)
    }

    private var includeUpstreamChanges: some View {
        Toggle(
            "Include upstream changes",
            isOn: $prefs.settings.sourceControl.general.includeUpstreamChanges
        )
        .toggleStyle(.checkbox)
        .padding(.leading, 20)
    }

    private var openCreatedIssueInBrowser: some View {
        Toggle(
            "Open created issue in the browser",
            isOn: $prefs.settings.sourceControl.general.openFeedbackInBrowser
        )
        .toggleStyle(.checkbox)
    }

    private var comparisonView: some View {
        Picker(
            "Comparison View",
            selection: $prefs.settings.sourceControl.general.revisionComparisonLayout
        ) {
            Text("Local Revision on Left Side")
                .tag(Settings.RevisionComparisonLayout.localLeft)
            Text("Local Revision on Right Side")
                .tag(Settings.RevisionComparisonLayout.localRight)
        }
        .frame(width: inputWidth)
    }

    private var sourceControlNavigator: some View {
        Picker(
            "Source Control Navigator",
            selection: $prefs.settings.sourceControl.general.controlNavigatorOrder
        ) {
            Text("Sort by Name")
                .tag(Settings.ControlNavigatorOrder.sortByName)
            Text("Sort by Date")
                .tag(Settings.ControlNavigatorOrder.sortByDate)
        }
        .frame(width: inputWidth)
    }

    @ViewBuilder
    private var defaultBranchName: some View {
        TextField("main", text: $branchName)
            .frame(width: inputWidth)
        Text("Branch names cannot contain spaces, backslashes, or other symbols")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
    }
}
