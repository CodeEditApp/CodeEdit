//
//  SourceControlGitView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGitView: View {

    // MARK: - View

    var body: some View {
        VStack {
            authorNameSection
            authorEmailSection
            ignoredFilesSection
            optionsSection
        }
            .frame(width: 715)
            .background(EffectView(.contentBackground))
    }

    private let inputWidth: Double = 280

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var ignoredFileSelection: IgnoredFiles.ID?
}

private extension SourceControlGitView {

    // MARK: - Sections

    private var authorNameSection: some View {
        PreferencesSection("Author Name", hideLabels: false) {
            gitAuthorName
        }
    }

    private var authorEmailSection: some View {
        PreferencesSection("Author Email", hideLabels: false) {
            gitEmail
        }
    }

    private var ignoredFilesSection: some View {
        PreferencesSection("Ignored Files", hideLabels: false, align: .top) {
            VStack(spacing: 1) {
                ignoredFiles
            }
            .frame(width: inputWidth)
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
        }
    }

    private var optionsSection: some View {
        PreferencesSection("Options", hideLabels: false) {
            preferToRebaseWhenPulling
            showMergeCommitsInPerFileLog
        }
    }

    // MARK: - Preference Views

    private var gitAuthorName: some View {
        TextField("Git Author Name", text: $prefs.preferences.sourceControl.git.authorName)
            .frame(width: inputWidth)
    }

    private var gitEmail: some View {
        TextField("Git Email", text: $prefs.preferences.sourceControl.git.authorEmail)
            .frame(width: inputWidth)
    }

    @ViewBuilder
    private var ignoredFiles: some View {
        List(
            $prefs.preferences.sourceControl.git.ignoredFiles,
            selection: $ignoredFileSelection
        ) { ignoredFile in
            IgnoredFileView(ignoredFile: ignoredFile)
        }
        .overlay(Group {
            if prefs.preferences.sourceControl.git.ignoredFiles.isEmpty {
                Text("No Ignored Files")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
            }
        })
        .frame(height: 150)
        PreferencesToolbar(height: 22) {
            bottomToolbar
        }
    }

    private var preferToRebaseWhenPulling: some View {
        Toggle(
            "Prefer to rebase when pulling",
            isOn: $prefs.preferences.sourceControl.git.preferRebaseWhenPulling
        )
        .toggleStyle(.checkbox)
        .frame(width: inputWidth, alignment: .leading)
    }

    private var showMergeCommitsInPerFileLog: some View {
        Toggle(
            "Show merge commits in per-file log",
            isOn: $prefs.preferences.sourceControl.git.showMergeCommitsPerFileLog
        )
        .toggleStyle(.checkbox)
        .frame(width: inputWidth, alignment: .leading)
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
