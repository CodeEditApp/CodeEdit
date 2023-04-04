//
//  SettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import AppKit

/// A struct for `SettingsView`
struct SettingsView: View {

    /// An array of NavigationItems
    private static let pages: [SettingsPage] = [
        .init(.general, baseColor: .gray, icon: .system("gear")),
        .init(.account, baseColor: .blue, icon: .system("at")),
        .init(.behaviors, baseColor: .orange, icon: .system("flowchart")),
        .init(.navigation, baseColor: .green, icon: .system("arrow.triangle.turn.up.right.diamond")),
        .init(.themes, baseColor: .pink, icon: .system("paintbrush")),
        .init(.textEditing, baseColor: .blue, icon: .system("square.and.pencil")),
        .init(.terminal, baseColor: .blue, icon: .system("terminal")),
        .init(.keybindings, baseColor: .gray, icon: .system("keyboard")),
        .init(.sourceControl, baseColor: .blue, icon: .system("arrow.triangle.pull")),
        .init(.components, baseColor: .blue, icon: .system("puzzlepiece")),
        .init(.locations, baseColor: .green, icon: .system("externaldrive")),
        .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
        /*
        .init(.extensionsSection, children: [
            // iterate over extensions
            .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
            .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
            .init(.advanced, baseColor: .gray, icon: .system("gearshape.2"))
        ])
        */
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
                    GeneralSettingsView()
                        .environmentObject(updater)
                case .themes:
                    ThemeSettingsView()
                case .textEditing:
                    TextEditingSettingsView()
                case .terminal:
                    TerminalSettingsView()
                case .sourceControl:
                    SourceControlSettingsView()
                case .locations:
                    LocationsSettingsView()
                default:
                    Text("Implementation Needed")
                        .frame(alignment: .center)
                }
            }
            .navigationSplitViewColumnWidth(500)
        }
        // .searchable(text: $searchText, placement: .sidebar)
        .navigationTitle(selectedPage.name.rawValue)
    }
}
