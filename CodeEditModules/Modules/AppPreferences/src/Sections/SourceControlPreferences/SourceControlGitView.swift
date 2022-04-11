//
//  SourceControlGitView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGitView: View {

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        PreferencesContent {
            PreferencesSection("Author Name") {
                TextField("Git Author Name", text: $prefs.preferences.sourceControl.git.authorName)
                    .frame(width: 280)
            }

            PreferencesSection("Author Email") {
                TextField("Git Email", text: $prefs.preferences.sourceControl.git.authorEmail)
                    .frame(width: 280)
            }

            PreferencesSection("Ignored Files") {
                List {
                    Text("*~")
                }
                .frame(width: 280, height: 180)
                .background(Color(NSColor.textBackgroundColor))
            }

            PreferencesSection("Options") {
                Toggle("Prefer to rebase when pulling",
                       isOn: $prefs.preferences.sourceControl.git.preferRebaseWhenPulling)
                    .toggleStyle(.checkbox)
                    .frame(width: 280, alignment: .leading)
                Toggle("Show merge commits in per-file log",
                       isOn: $prefs.preferences.sourceControl.git.showMergeCommitsPerFileLog)
                    .toggleStyle(.checkbox)
                    .frame(width: 280, alignment: .leading)
            }
        }
        .frame(width: 844, height: 350)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SourceControlGitView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGitView()
    }
}
