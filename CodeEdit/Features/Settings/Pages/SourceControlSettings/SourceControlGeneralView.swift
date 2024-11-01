//
//  SourceControlGeneralView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlGeneralView: View {
    @AppSettings(\.sourceControl.general)
    var settings

    let gitConfig = GitConfigClient(shellClient: currentWorld.shellClient)

    @State private var defaultBranch: String = ""
    @State private var hasAppeared = false

    var body: some View {
        SettingsForm {
            Section("Source Control") {
                enableSourceControl
                refreshLocalStatusAuto
                fetchRefreshStatusAuto
                addRemoveFilesAuto
                selectFilesToCommitAuto
            }
            Section("Text Editing") {
                showSourceControlChanges
                includeUpstreamChanges
            }
            Section {
                comparisonView
                sourceControlNavigator
                defaultBranchName
            }
        }
        .onAppear {
            Task {
                defaultBranch = try await gitConfig.get(key: "init.defaultBranch", global: true) ?? ""
                Task {
                    hasAppeared = true
                }
            }
        }
    }
}

private extension SourceControlGeneralView {
    private var enableSourceControl: some View {
        Toggle(
            "Enable source control",
            isOn: $settings.enableSourceControl
        )
    }

    private var refreshLocalStatusAuto: some View {
        Toggle(
            "Refresh local status automatically",
            isOn: $settings.refreshStatusLocally
        )
        .disabled(!settings.enableSourceControl)
    }

    private var fetchRefreshStatusAuto: some View {
        Toggle(
            "Fetch and refresh server status automatically",
            isOn: $settings.fetchRefreshServerStatus
        )
        .disabled(!settings.enableSourceControl)
    }

    private var addRemoveFilesAuto: some View {
        Toggle(
            "Add and remove files automatically",
            isOn: $settings.addRemoveAutomatically
        )
        .disabled(!settings.enableSourceControl)
    }

    private var selectFilesToCommitAuto: some View {
        Toggle(
            "Select files to commit automatically",
            isOn: $settings.selectFilesToCommit
        )
        .disabled(!settings.enableSourceControl)
    }

    private var showSourceControlChanges: some View {
        Toggle(
            "Show source control changes",
            isOn: $settings.showSourceControlChanges
        )
        .disabled(!settings.enableSourceControl)
    }

    private var includeUpstreamChanges: some View {
        Toggle(
            "Include upstream changes",
            isOn: $settings.includeUpstreamChanges
        )
        .disabled(!settings.enableSourceControl || !settings.showSourceControlChanges)
    }

    private var comparisonView: some View {
        Picker(
            "Comparison view",
            selection: $settings.revisionComparisonLayout
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
            selection: $settings.controlNavigatorOrder
        ) {
            Text("Sort by Name")
                .tag(SettingsData.ControlNavigatorOrder.sortByName)
            Text("Sort by Date")
                .tag(SettingsData.ControlNavigatorOrder.sortByDate)
        }
    }

    private var defaultBranchName: some View {
        TextField(text: $defaultBranch) {
            Text("Default branch name")
            Text("Cannot contain spaces, backslashes, or other symbols")
        }
        .onChange(of: defaultBranch) { newValue in
            if hasAppeared {
                Limiter.debounce(id: "defaultBranchDebouncer", duration: 0.5) {
                    Task {
                        await gitConfig.set(key: "init.defaultBranch", value: newValue, global: true)
                    }
                }
            }
        }
    }
}
