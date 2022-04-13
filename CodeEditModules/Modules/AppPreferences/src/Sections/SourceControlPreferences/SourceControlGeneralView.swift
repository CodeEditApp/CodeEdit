//
//  SourceControlGeneralView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGeneralView: View {

    @State var isChecked: Bool
    @State var branchName: String

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        PreferencesContent {

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
                .padding(.leading, 10)
            }

            PreferencesSection("Text Editing", hideLabels: false) {
                Toggle("Show Source Control chnages",
                       isOn: $prefs.preferences.sourceControl.general.showSourceControlChanges)
                    .toggleStyle(.checkbox)

                Toggle("Include upstream changes",
                       isOn: $prefs.preferences.sourceControl.general.includeUpstreamChanges)
                    .toggleStyle(.checkbox)
                    .padding(.leading, 20)
            }

            PreferencesSection("Comparison View", hideLabels: false) {
                Menu {
                    Button("Comparison") {}
                } label: {
                    Text("Local Revision on Left Side")
                        .font(.system(size: 11))
                }.frame(maxWidth: 170)
            }

            PreferencesSection("Source Control Navigator", hideLabels: false) {
                Menu {
                    Button("Control Navigator") {}
                } label: {
                    Text("Sort by Name")
                        .font(.system(size: 11))
                }.frame(maxWidth: 170)
            }

            PreferencesSection("Default Branch Name", hideLabels: false) {
                TextField("Text", text: $branchName)
                    .frame(width: 170)
                Text("Branch names cannot contain spaces, backslashes, or other symbols")
                    .font(.system(size: 12))
            }
        }
        .frame(width: 844, height: 350)
        .background(Color(NSColor.controlBackgroundColor))

    }
}

struct SourceControlGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGeneralView(isChecked: true, branchName: "main")
    }
}
