//
//  SourceControlGitView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 02/04/23.
//

import SwiftUI

struct SourceControlGitView: View {
    @AppSettings var settings

    @State
    var ignoredFileSelection: IgnoredFiles.ID?

    var body: some View {
        SettingsForm {
            Section {
                gitAuthorName
                gitEmail
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
        TextField("Author Name", text: $settings.sourceControl.git.authorName)
    }

    private var gitEmail: some View {
        TextField("Author Email", text: $settings.sourceControl.git.authorEmail)
    }

    private var preferToRebaseWhenPulling: some View {
        Toggle(
            "Prefer to rebase when pulling",
            isOn: $settings.sourceControl.git.preferRebaseWhenPulling
        )
    }

    private var showMergeCommitsInPerFileLog: some View {
        Toggle(
            "Show merge commits in per-file log",
            isOn: $settings.sourceControl.git.showMergeCommitsPerFileLog
        )
    }

    private var bottomToolbar: some View {
        HStack(spacing: 12) {
            Button {} label: {
                Image(systemName: "plus")
                    .foregroundColor(Color.secondary)
            }
            .buttonStyle(.plain)
            Button {} label: {
                Image(systemName: "minus")
            }
            .disabled(true)
            .buttonStyle(.plain)
            Spacer()
        }
    }
}
