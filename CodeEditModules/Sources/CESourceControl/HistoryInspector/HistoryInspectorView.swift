//
//  HistoryInspectorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/03/24.
//
import SwiftUI
import CodeEditSettings
import CodeEditUI
import CodeEditCore

struct HistoryInspectorView: View {
    @SettingsValue(SourceControlSettings.self, \.git.showMergeCommitsPerFileLog)
    var showMergeCommitsPerFileLog

    @EnvironmentObject private var sourceControlManager: SourceControlManager

    /// The active-file read-model, injected rather than read from the environment: the
    /// `\.activeEditorState` key is declared in the app shell and this view now ships in
    /// `CESourceControl`.
    private let activeEditorState: ActiveEditorState

    @EnvironmentObject private var settingsStore: PersistentSettingsStore

    @ObservedObject private var model: HistoryInspectorModel

    @State var selection: GitCommit?

    /// - Parameter activeEditorState: the workspace's active-file read-model; the history shown
    ///   follows its selection.
    init(activeEditorState: ActiveEditorState) {
        self.activeEditorState = activeEditorState
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
                CEContentUnavailableView("No Selection")
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
            model.settingsAccessor = settingsStore
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
