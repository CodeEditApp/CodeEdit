//
//  HistoryInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import CESourceControl
import SwiftUI
import CodeEditSettings
import CodeEditUI
import CodeEditCore

struct HistoryInspectorView: View {
    @SettingsValue(SourceControlSettings.self, \.git.showMergeCommitsPerFileLog)
    var showMergeCommitsPerFileLog

    @EnvironmentObject private var sourceControlManager: SourceControlManager

    @Environment(\.activeEditorState)
    private var activeEditorState

    @Environment(\.settingsAccessor)
    private var settingsAccessor

    @ObservedObject private var model: HistoryInspectorModel

    @State var selection: GitCommit?

    /// Initialize with GitClient
    /// - Parameter gitClient: a GitClient
    init() {
        self.model = .init()
    }

    var body: some View {
        Group {
            if model.sourceControlManager != nil {
                VStack {
                    if model.commitHistory.isEmpty {
                        CEContentUnavailableView("No History")
                    } else {
                        List(selection: $selection) {
                            ForEach(model.commitHistory) { commit in
                                HistoryInspectorItemView(commit: commit, selection: $selection)
                                    .tag(commit)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
            } else {
                NoSelectionInspectorView()
            }
        }
        .onReceive(activeEditorState.selectedFilePublisher) { file in
            Task {
                await model.setFile(url: file?.url.path())
            }
        }
        .task {
            // The model is created by this view, so this view configures it — the same shape as
            // `setWorkspace` below.
            model.settingsAccessor = settingsAccessor
            await model.setWorkspace(sourceControlManager: sourceControlManager)
            await model.setFile(url: activeEditorState.selectedFile?.url.path())
        }
        .onChange(of: showMergeCommitsPerFileLog) { _, _ in
            Task {
                await model.updateCommitHistory()
            }
        }
    }
}
