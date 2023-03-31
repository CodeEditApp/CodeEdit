//
//  VenturaPreferences.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import CodeEditSymbols
import AppKit

/// A struct for a Ventura-style preference
struct VenturaPreferences: View {

    /// An array of navigationItem(s)
    private static let pages: [Page] = [
        .init(.appPreferencesSection, children: [
            .init(
                .generalPreferences,
                icon: .init(
                    baseColor: Colors().gray,
                    systemName: "gear",
                    icon: .system("gear")
                )
            ),
            .init(
                .accountPreferences,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "at",
                    icon: .system("at")
                )
            ),
            .init(
                .behaviorPreferences,
                icon: .init(
                    baseColor: Colors().orange,
                    systemName: "flowchart",
                    icon: .system("flowchart")
                )
            ),
            .init(
                .navigationPreferences,
                icon: .init(
                    baseColor: Colors().green,
                    systemName: "arrow.triangle.turn.up.right.diamond",
                    icon: .system("arrow.triangle.turn.up.right.diamond")
                )
            ),
            .init(
                .themePreferences,
                icon: .init(
                    baseColor: Colors().pink,
                    systemName: "paintbrush",
                    icon: .system("paintbrush")
                )
            ),
            .init(
                .textEditingPreferences,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "square.and.pencil",
                    icon: .system("square.and.pencil")
                )
            ),
            .init(
                .terminalPreferences,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "terminal",
                    icon: .system("terminal")
                )
            ),
            .init(
                .keybindingsPreferences,
                icon: .init(
                    baseColor: Colors().gray,
                    systemName: "keyboard",
                    icon: .system("keyboard")
                )
            ),
            .init(
                .sourceControlPreferences,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "arrow.triangle.pull",
                    icon: .system("arrow.triangle.pull")
                )
            ),
            .init(
                .componentsPreferences,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "puzzlepiece",
                    icon: .system("puzzlepiece")
                )
            ),
            .init(
                .locationPreferences,
                icon: .init(
                    baseColor: Colors().green,
                    systemName: "externaldrive",
                    icon: .system("externaldrive")
                )
            ),
            .init(
                .advancedPreferences,
                icon: .init(
                    baseColor: Colors().gray,
                    systemName: "gearshape.2",
                    icon: .system("gearshape.2")
                )
            )
        ])
    ]

    /// Variables for the selected Page, the current search text and software updater
    @State private var selectedPage = pages.first?.children?.first
    @State private var searchText: String = ""
    let updater: SoftwareUpdater

    @ViewBuilder
    /// Generates a NavigationItem from a Page
    private func navigationItem(item: Page) -> some View {
        if searchText.isEmpty || item.name.rawValue.lowercased().contains(searchText.lowercased()) {
            NavigationLink(value: item) {
                Label {
                    Text(item.nameString)
                        .font(.system(size: 12))
                        .padding(.leading, 15)
                } icon: {
                    if let icon = item.icon {
                        Group {
                            Image(systemName: item.icon.systemName)
                        }
                        .foregroundColor(.primary)
                        .frame(width: 20, height: 20)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 5,
                                style: .continuous
                            )
                                .fill(icon.baseColor.gradient)
                        )
                            .padding(.leading, 20)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(Self.pages, selection: $selectedPage) { category in
                Section(category.nameString) {
                    if category.children != nil {
                        // Can force un-wrap because we checked if it was nil
                        ForEach(category.children!) { child in
                            navigationItem(item: child)
                        }
                    }
                }
            }
                .navigationSplitViewColumnWidth(215)
        } detail: {
            ScrollView {
                // TODO: Align left
                Text("\(selectedPage?.name.rawValue ?? "General") Preferences")
                    .font(.headline)
                    .fontWeight(.bold)
                // TODO: Scale font size (and position) to detail: bounds
                Group {
                    if selectedPage?.name != nil {
                        // Can force un-wrap because we just checked if it was nil
                        switch selectedPage!.name {
                        case .generalPreferences:
                            GeneralPreferencesView()
                                .environmentObject(updater)
                                .navigationTitle("General")
                        case .themePreferences:
                            ThemePreferencesView()
                                .navigationTitle("Themes")
                        case .textEditingPreferences:
                            TextEditingPreferencesView()
                                .navigationTitle("Text Editing")
                        case .terminalPreferences:
                            TerminalPreferencesView()
                                .navigationTitle("Terminal")
                        case .sourceControlPreferences:
                            SourceControlPreferencesView()
                                .navigationTitle("Source Control")
                        case .locationPreferences:
                            LocationsPreferencesView()
                                .navigationTitle("Locations")
                        default:
                            Text("Implementation Needed")
                                .frame(alignment: .center)
                        }
                    }
                }
                .padding(20)
            }
            .navigationSplitViewColumnWidth(715)
        } .task {
            /// Loops through all windows
            for window in NSApp.windows where window.title == "CodeEdit Settings" {
                /// We've found the settings page, let's apply the settings to it
                window.toolbarStyle = .unifiedCompact
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert([NSWindow.StyleMask.fullSizeContentView, NSWindow.StyleMask.miniaturizable])
                // TODO: This doesn't work, find out why and fix and make window vertically resizable
                window.styleMask.insert(NSWindow.StyleMask.resizable)
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search")
        .frame(width: 1200, height: 750)
    }
}
