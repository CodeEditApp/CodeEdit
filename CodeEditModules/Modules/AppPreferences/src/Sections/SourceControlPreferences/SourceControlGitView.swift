//
//  SourceControlGitView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI
import CodeEditUI

struct SourceControlGitView: View {

    @State var ignoredFileSelection: IgnoredFiles.ID?

    @StateObject
    private var prefs: AppPreferencesModel = .shared

    var body: some View {
        VStack {
            PreferencesSection("Author Name", hideLabels: false) {
                TextField("Git Author Name", text: $prefs.preferences.sourceControl.git.authorName)
                    .frame(width: 280)
            }

            PreferencesSection("Author Email", hideLabels: false) {
                TextField("Git Email", text: $prefs.preferences.sourceControl.git.authorEmail)
                    .frame(width: 280)
            }

            PreferencesSection("Ignored Files", hideLabels: false) {
                VStack(spacing: 1) {
                    List($prefs.preferences.sourceControl.git.ignoredFiles,
                         selection: $ignoredFileSelection) { ignoredFile in
                        IgnoredFileView(ignoredFile: ignoredFile)
                    }
                    .overlay(Group {
                        Color(NSColor.controlBackgroundColor)
                    })
                    .overlay(Group {
                        if prefs.preferences.sourceControl.git.ignoredFiles.isEmpty {
                            Text("No Ignored Files")
                        }
                    })
                    .frame(width: 280, height: 150)
                    PreferencesToolbar {
                        bottomToolbar
                    }
                    .frame(width: 280, height: 27)
                }
                .padding(1)
                .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            }

            PreferencesSection("Options", hideLabels: false) {
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
        .frame(height: 350)
        .background(EffectView(material: .contentBackground))
    }

    private var bottomToolbar: some View {
        HStack {
            Button {} label: {
                Image(systemName: "plus")
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
