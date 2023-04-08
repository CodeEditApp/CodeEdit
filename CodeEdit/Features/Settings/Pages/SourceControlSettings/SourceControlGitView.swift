//
//  SourceControlGitView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlGitView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        SettingsForm {
            Section {
                gitAuthorName
                gitEmail
            }
            Section {
                ignoredFilesText
            }
            Section {
                preferToRebaseWhenPulling
                showMergeCommitsInPerFileLog
            }
        }
    }
}

private extension SourceControlGitView {
    private var gitAuthorName: some View {
        TextField("Author Name", text: $prefs.preferences.sourceControl.git.authorName)
    }

    private var gitEmail: some View {
        TextField("Author Email", text: $prefs.preferences.sourceControl.git.authorEmail)
    }

    private var ignoredFilesText: some View {
        LabeledContent("Ignored files") {
            Button("Select files...") {
                // TODO: Implement a view (that works) for this
            }
            .disabled(true)
            .help("Not implemented yet")
        }
    }

    private var preferToRebaseWhenPulling: some View {
        Toggle(
            "Prefer to rebase when pulling",
            isOn: $prefs.preferences.sourceControl.git.preferRebaseWhenPulling
        )
    }

    private var showMergeCommitsInPerFileLog: some View {
        Toggle(
            "Show merge commits in per-file log",
            isOn: $prefs.preferences.sourceControl.git.showMergeCommitsPerFileLog
        )
    }
}
