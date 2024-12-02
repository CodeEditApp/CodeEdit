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

    var body: some View {
        SettingsForm {
            Section {
                sourceControlIsEnabled
            }
            Section("Source Control") {
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
            }
        }
    }
}

private extension SourceControlGeneralView {
    private var sourceControlIsEnabled: some View {
        Toggle(
            isOn: $settings.sourceControlIsEnabled
        ) {
            Label {
                Text("Source Control")
                Text("""
                 Back up your files, collaborate with others, and tag your releases. \
                 [Learn more...](https://developer.apple.com/documentation/xcode/source-control-management)
                 """)
                .font(.callout)
             } icon: {
                FeatureIcon(symbol: Image(symbol: "vault"), color: Color(.systemBlue), size: 26)
            }
        }
        .controlSize(.large)
    }

    private var refreshLocalStatusAuto: some View {
        Toggle(
            "Refresh local status automatically",
            isOn: $settings.refreshStatusLocally
        )
        .disabled(!settings.sourceControlIsEnabled)
    }

    private var fetchRefreshStatusAuto: some View {
        Toggle(
            "Fetch and refresh server status automatically",
            isOn: $settings.fetchRefreshServerStatus
        )
        .disabled(!settings.sourceControlIsEnabled)
    }

    private var addRemoveFilesAuto: some View {
        Toggle(
            "Add and remove files automatically",
            isOn: $settings.addRemoveAutomatically
        )
        .disabled(!settings.sourceControlIsEnabled)
    }

    private var selectFilesToCommitAuto: some View {
        Toggle(
            "Select files to commit automatically",
            isOn: $settings.selectFilesToCommit
        )
        .disabled(!settings.sourceControlIsEnabled)
    }

    private var showSourceControlChanges: some View {
        Toggle(
            "Show source control changes",
            isOn: $settings.showSourceControlChanges
        )
        .disabled(!settings.sourceControlIsEnabled)
    }

    private var includeUpstreamChanges: some View {
        Toggle(
            "Include upstream changes",
            isOn: $settings.includeUpstreamChanges
        )
        .disabled(!settings.sourceControlIsEnabled || !settings.showSourceControlChanges)
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
}
