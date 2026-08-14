//
//  SourceControlNavigatorView.swift
//  CodeEdit
//
//  Created by Nanashi Li on 2022/05/20.
//

import SwiftUI
import CodeEditCore
import CodeEditSettings
import CodeEditUI

struct SourceControlNavigatorView: View {
    @EnvironmentObject private var sourceControlManager: SourceControlManager
    @EnvironmentObject private var sourceControlViewModel: SourceControlViewModel

    @SettingsValue(SourceControlSettings.self, \.general.fetchRefreshServerStatus)
    var fetchRefreshServerStatus

    /// The command interface used to open a changed file. Injected rather than read from the
    /// environment, so the app shell stays the only place that knows where it comes from.
    private let navigator: WorkspaceNavigator

    init(navigator: WorkspaceNavigator) {
        self.navigator = navigator
    }

    var body: some View {
        VStack(spacing: 0) {
            SourceControlNavigatorTabs(navigator: navigator)
                .environmentObject(sourceControlManager)
                .environmentObject(sourceControlViewModel)
                .task {
                    do {
                        while true {
                            if fetchRefreshServerStatus {
                                try await sourceControlManager.fetch()
                            }
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
                .environmentObject(sourceControlViewModel)
        }
    }
}

struct SourceControlNavigatorTabs: View {
    @EnvironmentObject var sourceControlManager: SourceControlManager
    @State private var selectedSection: Int = 0

    let navigator: WorkspaceNavigator

    var body: some View {
        if sourceControlManager.isGitRepository {
            SegmentedControl(
                $selectedSection,
                options: ["Changes", "History", "Repository"],
                prominent: true
            )
            .frame(maxWidth: .infinity)
            .frame(height: 27)
            .padding(.horizontal, 8)
            Divider()
            if selectedSection == 0 {
                SourceControlNavigatorChangesView(navigator: navigator)
            }
            if selectedSection == 1 {
                SourceControlNavigatorHistoryView()
            }
            if selectedSection == 2 {
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
