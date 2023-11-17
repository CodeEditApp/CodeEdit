//
//  SourceControlNavigatorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI

struct SourceControlNavigatorView: View {
    @EnvironmentObject private var workspace: WorkspaceDocument

    var body: some View {
        VStack(spacing: 0) {
            if let sourceControlManager = workspace.workspaceFileManager?.sourceControlManager {
                SourcControlNavigatorTabs(sourceControlManager: sourceControlManager)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SourceControlNavigatorToolbarBottom()
        }
    }
}

struct SourcControlNavigatorTabs: View {
    @ObservedObject var sourceControlManager: SourceControlManager
    @State private var selectedSection: Int = 0

    var body: some View {
        if sourceControlManager.isGitRepository {
            SegmentedControl(
                $selectedSection,
                options: ["Changes", "Repositories"],
                prominent: true
            )
            .frame(maxWidth: .infinity)
            .frame(height: 26)
            .padding(.horizontal, 8)
            Divider()
            if selectedSection == 0 {
                SourceControlNavigatorChangesView(
                    sourceControlManager: sourceControlManager
                )
            }
            if selectedSection == 1 {
                SourceControlNavigatorRepositoriesView(
                    sourceControlManager: sourceControlManager
                )
            }
        } else {
            VStack {
                Text("Not a repository")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                Button("Initiate") {
                    Task {
                        try await sourceControlManager.initiate()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
