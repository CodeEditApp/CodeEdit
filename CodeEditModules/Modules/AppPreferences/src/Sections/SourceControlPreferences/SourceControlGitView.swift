//
//  SourceControlGitView.swift
//  
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct SourceControlGitView: View {

    @State var ignoredFileSelection: IgnoredFiles.ID?

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
                if prefs.preferences.sourceControl.git.ignoredFiles.isEmpty {
                    Text("No Ignored Files")
                        .background(Color(NSColor.textBackgroundColor))
                } else {
                    List($prefs.preferences.sourceControl.git.ignoredFiles,
                         selection: $ignoredFileSelection) { ignoredFile in
                        IgnoredFileView(ignoredFile: ignoredFile)
                    }
                    .frame(width: 280, height: 180)
                    .background(Color(NSColor.textBackgroundColor))
                }
                toolbar {
                    bottomToolbar
                }.frame(width: 280, height: 27)
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

    private func toolbar<T: View>(
        height: Double = 27,
        bgColor: Color = Color(NSColor.controlBackgroundColor),
        @ViewBuilder content: @escaping () -> T
    ) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(bgColor)
            HStack {
                content()
                    .padding(.horizontal, 8)
            }
        }
        .frame(height: height)
    }
}

struct SourceControlGitView_Previews: PreviewProvider {
    static var previews: some View {
        SourceControlGitView().preferredColorScheme(.dark)
    }
}
