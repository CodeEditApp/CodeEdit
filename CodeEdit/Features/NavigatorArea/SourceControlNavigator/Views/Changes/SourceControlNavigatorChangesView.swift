//
//  SourceControlNavigatorChangesView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorChangesView: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager

    var hasRemotes: Bool {
        !sourceControlManager.remotes.isEmpty
    }

    var hasUnpushedCommits: Bool {
        sourceControlManager.numberOfUnpushedCommits > 0
    }

    var hasCurrentBranch: Bool {
        (sourceControlManager.currentBranch != nil && sourceControlManager.currentBranch?.upstream == nil)
    }

    var hasChanges: Bool {
        !sourceControlManager.changedFiles.isEmpty
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if hasChanges || !hasRemotes || (!hasChanges && (hasUnpushedCommits || hasCurrentBranch)) {
                VStack(spacing: 8) {
                    Divided {
                        if hasChanges {
                            SourceControlNavigatorChangesCommitView()
                        }
                        if !hasRemotes {
                            SourceControlNavigatorNoRemotesView()
                        }
                        if !hasChanges && (hasUnpushedCommits || hasCurrentBranch) {
                            SourceControlNavigatorPushView(sourceControlManager: sourceControlManager)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                Divider()
            }
            if hasChanges {
                SourceControlNavigatorChangesList()
            } else {
                CEContentUnavailableView("No Changes")
            }
        }
        .frame(maxHeight: .infinity)
        .task {
            await sourceControlManager.refreshAllChangedFiles()
            await sourceControlManager.refreshNumberOfUnsyncedCommits()
        }

    }
}
