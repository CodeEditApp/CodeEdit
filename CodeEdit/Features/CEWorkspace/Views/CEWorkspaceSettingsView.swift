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
    @Environment(\.colorScheme)
    private var colorScheme

    /// Variables for the selected Page, the current search text and software updater
    @State private var selectedPage: CEWorkspaceSettingsPage = Self.pages[0].page
    @State private var searchText: String = ""

    @Environment(\.presentationMode)
    var presentationMode

    static var pages: [PageAndCEWorkspaceSettings] = [
        .init(
            CEWorkspaceSettingsPage(
                .general,
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
