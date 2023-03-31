//
//  Settings.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import CodeEditSymbols
import AppKit

/// A struct for Settings
struct Settings: View {

    /// An array of navigationItem(s)
    private static let pages: [Page] = [
        .init(.settingsSection, children: [
            .init(
                .generalSettings,
                icon: .init(
                    baseColor: Colors().gray,
                    systemName: "gear",
                    icon: .system("gear")
                )
            ),
            .init(
                .accountSettings,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "at",
                    icon: .system("at")
                )
            ),
            .init(
                .behaviorSettings,
                icon: .init(
                    baseColor: Colors().orange,
                    systemName: "flowchart",
                    icon: .system("flowchart")
                )
            ),
            .init(
                .navigationSettings,
                icon: .init(
                    baseColor: Colors().green,
                    systemName: "arrow.triangle.turn.up.right.diamond",
                    icon: .system("arrow.triangle.turn.up.right.diamond")
                )
            ),
            .init(
                .themeSettings,
                icon: .init(
                    baseColor: Colors().pink,
                    systemName: "paintbrush",
                    icon: .system("paintbrush")
                )
            ),
            .init(
                .textEditingSettings,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "square.and.pencil",
                    icon: .system("square.and.pencil")
                )
            ),
            .init(
                .terminalSettings,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "terminal",
                    icon: .system("terminal")
                )
            ),
            .init(
                .keybindingsSettings,
                icon: .init(
                    baseColor: Colors().gray,
                    systemName: "keyboard",
                    icon: .system("keyboard")
                )
            ),
            .init(
                .sourceControlSettings,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "arrow.triangle.pull",
                    icon: .system("arrow.triangle.pull")
                )
            ),
            .init(
                .componentsSettings,
                icon: .init(
                    baseColor: Colors().blue,
                    systemName: "puzzlepiece",
                    icon: .system("puzzlepiece")
                )
            ),
            .init(
                .locationSettings,
                icon: .init(
                    baseColor: Colors().green,
                    systemName: "externaldrive",
                    icon: .system("externaldrive")
                )
            ),
            .init(
                .advancedSettings,
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
    @State private var hidden: Bool = true
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
            VStack {
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
            }
        } detail: {
            ScrollView {
                // TODO: Align left
                Text(selectedPage?.nameString ?? "No selection")
                    .font(.headline)
                    .fontWeight(.bold)
                Group {
                    if selectedPage?.name != nil {
                        // Can force un-wrap because we just checked if it was nil
                        switch selectedPage!.name {
                        case .generalSettings:
                            GeneralSettingsView()
                                .environmentObject(updater)
                                .navigationTitle("General")
                        case .themeSettings:
                            ThemeSettingsView() // TODO: i think this is broken when i did the refactor, try to find what's wrong
                            // this might be a problem with fixed .frame() sizes
                                .navigationTitle("Themes")
                        case .textEditingSettings:
                            TextEditingSettingsView()
                                .navigationTitle("Text Editing")
                        case .terminalSettings:
                            TerminalSettingsView()
                                .navigationTitle("Terminal")
                        case .sourceControlSettings:
                            SourceControlSettingsView()
                                .navigationTitle("Source Control")
                                .navigationSubtitle("subtitle")
                        case .locationSettings:
                            LocationsSettingsView()
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
            print("run")
            NSApp.windows.second?.toolbarStyle = .unifiedCompact
            NSApp.windows.second?.titleVisibility = NSWindow.TitleVisibility.hidden
            NSApp.windows.second?.titlebarAppearsTransparent = true
            print(NSApp.windows.second?.title ?? "no title")
        }
        // TODO: Make window resizable
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search")
        .frame(width: 1200, height: 750)
        .opacity(hidden ? 1 : 0)
    }
}
