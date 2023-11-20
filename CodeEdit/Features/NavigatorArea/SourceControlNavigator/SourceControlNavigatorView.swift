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
                SourcControlNavigatorTabs()
                    .environmentObject(sourceControlManager)
                    .onAppear {
                        sourceControlManager.startPeriodicFetch(interval: 10)
                    }
                    .onDisappear {
                        sourceControlManager.stopPeriodicFetch()
                    }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SourceControlNavigatorToolbarBottom()
        }
    }
}

struct SourcControlNavigatorTabs: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
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
            .task {
                Task {
                    try await sourceControlManager.refreshRemotes()
                }
            }
            Divider()
            if selectedSection == 0 {
                SourceControlNavigatorChangesView()
            }
            if selectedSection == 1 {
                SourceControlNavigatorRepositoriesView()
            }
        } else {
            CEContentUnavailableView(
                "No Repository",
                 description: "This project is not a git repository.",
                 systemImage: "externaldrive.fill",
                 actions: {
                    Button("Initialize") {
                        Task {
                            try await sourceControlManager.initiate()
                        }
                    }
                }
            )
        }
    }
}
