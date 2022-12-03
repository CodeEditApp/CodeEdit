//
//  SourceControlGitView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGitView: View {
    private let inputWidth: Double = 280

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    @State
    var ignoredFileSelection: IgnoredFiles.ID?

    var body: some View {
        VStack {
            PreferencesSection("Author Name", hideLabels: false) {
                TextField("Git Author Name", text: $prefs.preferences.sourceControl.git.authorName)
                    .frame(width: inputWidth)
            }

            PreferencesSection("Author Email", hideLabels: false) {
                TextField("Git Email", text: $prefs.preferences.sourceControl.git.authorEmail)
                    .frame(width: inputWidth)
            }

            PreferencesSection("Ignored Files", hideLabels: false, align: .top) {
                VStack(spacing: 1) {
                    List($prefs.preferences.sourceControl.git.ignoredFiles,
                         selection: $ignoredFileSelection) { ignoredFile in
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
                .frame(width: inputWidth)
                .padding(1)
                .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            }

            PreferencesSection("Options", hideLabels: false) {
                Toggle("Prefer to rebase when pulling",
                       isOn: $prefs.preferences.sourceControl.git.preferRebaseWhenPulling)
                    .toggleStyle(.checkbox)
                    .frame(width: inputWidth, alignment: .leading)
                Toggle("Show merge commits in per-file log",
                       isOn: $prefs.preferences.sourceControl.git.showMergeCommitsPerFileLog)
                    .toggleStyle(.checkbox)
                    .frame(width: inputWidth, alignment: .leading)
            }
        }
        .frame(height: 350)
        .background(EffectView(.contentBackground))
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

struct SourceControlGitView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGitView().preferredColorScheme(.dark)
    }
}
