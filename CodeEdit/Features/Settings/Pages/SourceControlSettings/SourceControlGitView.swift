//
//  SourceControlGitView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

/// A view that implements the `Git` area of the `Source Control` settings page
struct SourceControlGitView: View {
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        Group {
            Section("Git") {
                authorNameAndEmail
            }
            Section {
                ignoredFiles
            }
            Section {
                options
            }
        }
        .formStyle(.grouped)
    }
}

private extension SourceControlGitView {
    // MARK: - Sections
    @ViewBuilder
    private var authorNameAndEmail: some View {
        gitAuthorName
        gitEmail
    }

    private var ignoredFiles: some View {
        ignoredFilesText
    }

    @ViewBuilder
    private var options: some View {
        preferToRebaseWhenPulling
        showMergeCommitsInPerFileLog
    }

    // MARK: - Preference Views
    private var gitAuthorName: some View {
        TextField("Git Author Name", text: $prefs.preferences.sourceControl.git.authorName)
    }

    private var gitEmail: some View {
        TextField("Git Email", text: $prefs.preferences.sourceControl.git.authorEmail)
    }

    @ViewBuilder
    private var ignoredFilesText: some View {
        HStack {
            Text("Ignored files")
            Spacer()
            Button("Select files...") {
                // TODO: Implement a view for this
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
