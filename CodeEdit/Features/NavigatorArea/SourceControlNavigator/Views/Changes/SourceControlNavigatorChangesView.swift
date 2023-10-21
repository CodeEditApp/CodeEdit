//
//  SourceControlNavigatorChangesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorChangesView: View {
    @ObservedObject var sourceControlManager: SourceControlManager

    var showSyncView: Bool {
        sourceControlManager.numberOfUnsyncedCommits > 0 ||
            (sourceControlManager.currentBranch != nil && sourceControlManager.currentBranch?.upstream == nil)
    }

    var body: some View {
        VStack(alignment: .center) {
            if sourceControlManager.changedFiles.isEmpty {
                if showSyncView {
                    SourceControlNavigatorSyncView(sourceControlManager: sourceControlManager)
                } else {
                    Text("No Changes")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            } else {
                SourceControlNavigatorChangesCommitView(
                    sourceControlManager: sourceControlManager
                )
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sourceControlManager.changedFiles) { file in
                            SourceControlNavigatorChangedFileView(
                                sourceControlManager: sourceControlManager,
                                changedFile: file
                            )
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .task {
            await sourceControlManager.refresAllChangesFiles()
            await sourceControlManager.refreshNumberOfUnsyncedCommits()
        }
    }
}
