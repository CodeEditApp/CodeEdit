//
//  CEWorkspaceSettingsView.swift
//  CodeEdit
//
//  Created by Axel Martinez on 26/3/24.
//

import SwiftUI
import CodeEditSymbols

/// A struct for settings
struct CEWorkspaceSettingsView: View {
    @ObservedObject var settings: CEWorkspaceSettings

    @StateObject var viewModel = SettingsViewModel()
    @State private var selectedPage: CEWorkspaceSettingsPage = Self.pages[0].page
    @State private var searchText: String = ""

    let window: NSWindow?
    let workspace: WorkspaceDocument

    static var pages: [PageAndCEWorkspaceSettings] = [
        .init(
            CEWorkspaceSettingsPage(
                .project,
                baseColor: .gray,
                icon: .system("gear")
            )
        ),
        .init(
            CEWorkspaceSettingsPage(
                .tasks,
                baseColor: .blue,
                icon: .system("at")
            )
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TasksCEWorkspaceSettingsView(
                workspace: workspace,
                projectSettings: $settings.preferences.project,
                settings: $settings.preferences.tasks
            )
            Spacer()
            Divider()
            HStack {
                Spacer()
                Button("Done") {
                    window?.close()
                }
            }
            .padding()
        }
        .environmentObject(viewModel)
    }
}
