//
//  CEWorkspaceSettingsView.swift
//  CodeEdit
//
//  Created by Axel Martinez on 26/3/24.
//

import SwiftUI
import CodeEditSymbols

/// A struct for settings
struct CEWorkspaceSettingsView {
    @StateObject var model = SettingsViewModel()

    /// Variables for the selected Page and the current search text
    @State private var selectedPage: CEWorkspaceSettingsPage = Self.pages[0].page
    @State private var searchText: String = ""

    @Environment(\.presentationMode)
    var presentationMode

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
        ),
    ]

    @ObservedObject private var settings: CEWorkspaceSettings = .shared

    var body: some View {
        ProjectCEWorkspaceSettingsView()
        TasksCEWorkspaceSettingsView()
            .environmentObject(model)
            .onAppear {
                selectedPage = Self.pages[0].page
            }
    }
}
