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
        if let sourceControlManager = workspace.workspaceFileManager?.sourceControlManager {
            VStack(spacing: 0) {
                SourcControlNavigatorTabs()
                    .environmentObject(sourceControlManager)
                    .task {
                        do {
                            while true {
                                try await sourceControlManager.fetch()
                                try await Task.sleep(for: .seconds(10))
                            }
                        } catch {
                            // TODO: if source fetching fails, display message
                        }
                    }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SourceControlNavigatorToolbarBottom()
                    .environmentObject(sourceControlManager)
            }
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
                options: ["Changes", "Repository"],
                prominent: true
            )
            .frame(maxWidth: .infinity)
            .frame(height: 26)
            .padding(.horizontal, 8)
            .task {
                do {
                    try await sourceControlManager.refreshRemotes()
                    try await sourceControlManager.refreshStashEntries()
                } catch {
                    await sourceControlManager.showAlertForError(title: "Error refreshing Git data", error: error)
                }
            }
            Divider()
            if selectedSection == 0 {
                SourceControlNavigatorChangesView()
            }
            if selectedSection == 1 {
                SourceControlNavigatorRepositoryView()
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
