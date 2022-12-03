//
//  SourceControlGeneralView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGeneralView: View {
    private let inputWidth: Double = 200

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var isChecked: Bool

    @State
    var branchName: String

    var body: some View {
        VStack {

            PreferencesSection("Source Control", hideLabels: false) {
                Toggle("Enable Source Control", isOn: $prefs.preferences.sourceControl.general.enableSourceControl)
                    .toggleStyle(.checkbox)

                VStack(alignment: .leading) {
                    Toggle("Refresh local status automatically",
                           isOn: $prefs.preferences.sourceControl.general.refreshStatusLocaly)
                        .toggleStyle(.checkbox)
                    Toggle("Fetch and refresh server status automatically",
                           isOn: $prefs.preferences.sourceControl.general.fetchRefreshServerStatus)
                        .toggleStyle(.checkbox)
                    Toggle("Add and remove files automatically",
                           isOn: $prefs.preferences.sourceControl.general.addRemoveAutomatically)
                        .toggleStyle(.checkbox)
                    Toggle("Select files to commit automatically",
                           isOn: $prefs.preferences.sourceControl.general.selectFilesToCommit)
                        .toggleStyle(.checkbox)
                }
                .padding(.leading, 20)
            }

            PreferencesSection("Text Editing", hideLabels: false) {
                Toggle("Show Source Control changes",
                       isOn: $prefs.preferences.sourceControl.general.showSourceControlChanges)
                    .toggleStyle(.checkbox)

                Toggle("Include upstream changes",
                       isOn: $prefs.preferences.sourceControl.general.includeUpstreamChanges)
                    .toggleStyle(.checkbox)
                    .padding(.leading, 20)
            }

            PreferencesSection("Reporting", hideLabels: false) {
                Toggle("Open created issue in the browser",
                       isOn: $prefs.preferences.sourceControl.general.openFeedbackInBrowser)
                    .toggleStyle(.checkbox)
            }

            PreferencesSection("Comparison View", hideLabels: true) {
                Picker("Comparison View",
                       selection: $prefs.preferences.sourceControl.general.revisionComparisonLayout) {
                    Text("Local Revision on Left Side")
                        .tag(AppPreferences.RevisionComparisonLayout.localLeft)
                    Text("Local Revision on Right Side")
                        .tag(AppPreferences.RevisionComparisonLayout.localRight)
                }
                .frame(width: inputWidth)
            }

            PreferencesSection("Source Control Navigator", hideLabels: true) {
                Picker("Source Control Navigator",
                       selection: $prefs.preferences.sourceControl.general.controlNavigatorOrder) {
                    Text("Sort by Name")
                        .tag(AppPreferences.ControlNavigatorOrder.sortByName)
                    Text("Sort by Date")
                        .tag(AppPreferences.ControlNavigatorOrder.sortByDate)
                }
                .frame(width: inputWidth)
            }

            PreferencesSection("Default Branch Name", hideLabels: false) {
                TextField("main", text: $branchName)
                    .frame(width: inputWidth)
                Text("Branch names cannot contain spaces, backslashes, or other symbols")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 350)
        .background(EffectView(.contentBackground))
    }
}

struct SourceControlGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGeneralView(isChecked: true, branchName: "main")
    }
}
