//
//  SettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import AppKit

/// A struct for settings
struct SettingsView: View {

    /// An array of navigationItem(s)
    private static let pages: [SettingsPage] = [
        .init(.general, baseColor: .gray, icon: .system("gear")),
        .init(.account, baseColor: .blue, icon: .system("at")),
        .init(.behavior, baseColor: .orange, icon: .system("flowchart")),
        .init(.navigation, baseColor: .green, icon: .system("arrow.triangle.turn.up.right.diamond")),
        .init(.theme, baseColor: .pink, icon: .system("paintbrush")),
        .init(.textEditing, baseColor: .blue, icon: .system("square.and.pencil")),
        .init(.terminal, baseColor: .blue, icon: .system("terminal")),
        .init(.keybindings, baseColor: .gray, icon: .system("keyboard")),
        .init(.sourceControl, baseColor: .blue, icon: .system("arrow.triangle.pull")),
        .init(.components, baseColor: .blue, icon: .system("puzzlepiece")),
        .init(.location, baseColor: .green, icon: .system("externaldrive")),
        .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
//        .init(.extensionsSection, children: [
//            // iterate over extensions
//            .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
//            .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
//            .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
//        ])
    ]

    /// Variables for the selected Page, the current search text and software updater
    @State private var selectedPage = pages.first!
    @State private var searchText: String = ""

    let updater: SoftwareUpdater

    var body: some View {
        NavigationSplitView {
            List(Self.pages, selection: $selectedPage) { item in
                if item.children.isEmpty {
                    if searchText.isEmpty || item.name.rawValue.lowercased().contains(searchText.lowercased()) {
                        SettingsPageView(item)
                    }
                } else {
                    Section(item.nameString) {
                        ForEach(item.children) { child in
                            if searchText.isEmpty || child.name.rawValue.lowercased().contains(
                                searchText.lowercased()
                            ) {
                                SettingsPageView(child)
                            }
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(215)
        } detail: {
            Group {
                switch selectedPage.name {
                case .general:
                    GeneralSettingsView().environmentObject(updater)
                case .theme:
                    ThemePreferencesView()
                case .textEditing:
                    TextEditingPreferencesView()
                case .terminal:
                    TerminalSettingsView()
                case .sourceControl:
                    SourceControlSettingsView()
                case .location:
                    LocationSettingsView()
                default:
                    Text("Implementation Needed").frame(alignment: .center)
                }
            }
            .navigationSplitViewColumnWidth(500)
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search")
        .navigationTitle(selectedPage.name.rawValue)
    }
}

