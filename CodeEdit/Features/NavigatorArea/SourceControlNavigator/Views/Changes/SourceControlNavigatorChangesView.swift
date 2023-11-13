//
//  SourceControlNavigatorChangesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorChangesView: View {
    @ObservedObject var sourceControlManager: SourceControlManager

    @State var selection = Set<CEWorkspaceFile>()

    var showSyncView: Bool {
        sourceControlManager.numberOfUnsyncedCommits > 0 ||
            (sourceControlManager.currentBranch != nil && sourceControlManager.currentBranch?.upstream == nil)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
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
                List(sourceControlManager.changedFiles, id: \.self, selection: $selection) { file in
                    SourceControlNavigatorChangedFileView(
                        sourceControlManager: sourceControlManager,
                        changedFile: file
                    )
                    .listRowSeparator(.hidden)
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
