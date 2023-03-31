//
//  VenturaPreferences.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import CodeEditSymbols

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

    func show() {
        hidden = false
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
                Group {
                    if selectedPage?.name != nil {
                        // Can force un-wrap because we just checked if it was nil
                        switch selectedPage!.name {
                        case .generalPreferences:
                            GeneralPreferencesView()
                                .environmentObject(updater)
                        case .themePreferences:
                            ThemePreferencesView()
                        case .textEditingPreferences:
                            TextEditingPreferencesView()
                        case .terminalPreferences:
                            TerminalPreferencesView()
                        case .sourceControlPreferences:
                            SourceControlPreferencesView()
                        case .locationPreferences:
                            LocationsPreferencesView()
                        default:
                            Text("Implementation Needed")
                                .frame(alignment: .center)
                        }
                    }
                }
                .padding(20)
                .frame(
                      minWidth: 0,
                      maxWidth: 715,
                      minHeight: 0,
                      maxHeight: 750,
                      alignment: .leading
                )
            }
            .navigationSplitViewColumnWidth(500)
        }
        // TODO: Make window resizable and remove window title
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search")
        .navigationTitle(selectedPage?.nameString ?? "Selection Error")
        .frame(width: 1200, height: 750)
        .opacity(hidden ? 1 : 0)
    }
}
