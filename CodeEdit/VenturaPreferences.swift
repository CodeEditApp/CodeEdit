//
//  VenturaPreferences.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import CodeEditSymbols

struct VenturaSettings: View {
    private static let pages: [Page] = [
        .init(.generalSection, children: [
            .init(
                .generalSettings,
                icon: .init(
                    baseColor: .gray,
                    systemName: "gear",
                    icon: .system("gear")
                )
            ),
            .init(
                .accountSettings,
                icon: .init(
                    baseColor: .blue,
                    systemName: "at",
                    icon: .system("at")
                )
            ),
            .init(
                .behaviorSettings,
                icon: .init(
                    baseColor: .orange,
                    systemName: "flowchart",
                    icon: .system("flowchart")
                )
            ),
            .init(
                .navigationSettings,
                icon: .init(
                    baseColor: .green,
                    systemName: "arrow.triangle.turn.up.right.diamond",
                    icon: .system("arrow.triangle.turn.up.right.diamond")
                )
            ),
            .init(
                .themeSettings,
                icon: .init(
                    baseColor: .pink,
                    systemName: "paintbrush",
                    icon: .system("paintbrush")
                )
            ),
            .init(
                .textEditingSettings,
                icon: .init(
                    baseColor: .cyan,
                    systemName: "square.and.pencil",
                    icon: .system("square.and.pencil")
                )
            ),
            .init(
                .terminalSettings,
                icon: .init(
                    baseColor: .cyan,
                    systemName: "terminal",
                    icon: .system("terminal")
                )
            ),
            .init(
                .keybindingsSettings,
                icon: .init(
                    baseColor: .gray,
                    systemName: "keyboard",
                    icon: .system("keyboard")
                )
            ),
            .init(
                .sourceControlSettings,
                icon: .init(
                    baseColor: .blue,
                    systemName: "arrow.triangle.pull",
                    icon: .system("arrow.triangle.pull")
                )
            ),
            .init(
                .componentsSettings,
                icon: .init(
                    baseColor: .blue,
                    systemName: "puzzlepiece",
                    icon: .system("puzzlepiece")
                )
            ),
            .init(
                .locationSettings,
                icon: .init(
                    baseColor: .green,
                    systemName: "externaldrive",
                    icon: .system("externaldrive")
                )
            ),
            .init(
                .advancedSettings,
                icon: .init(
                    baseColor: .gray,
                    systemName: "gearshape.2",
                    icon: .system("gearshape.2")
                )
            )
        ])
    ]

    @State private var selectedPage = pages.first?.children?.first
    @State private var filter: String = ""
    @State private var hidden: Bool = true
    let updater: SoftwareUpdater

    @ViewBuilder
    private func navigationItem(item: Page) -> some View {
        if filter.isEmpty || item.name.rawValue.lowercased().contains(filter.lowercased()) {
            NavigationLink(value: item) {
                Label {
                    Text(item.nameString)
                } icon: {
                    if let icon = item.icon {
                        Group {
                            Image(systemName: item.icon.systemName)
                        }
                        .foregroundColor(.primary)
                        .frame(width: 15, height: 15)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 5,
                                style: .continuous
                            )
                                .fill(icon.baseColor.gradient)
                        )
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
                        ForEach(category.children!) { child in
                            navigationItem(item: child)
                        }
                    }
                }
            }
                .navigationSplitViewColumnWidth(215)
        } detail: {
            ScrollView {
                VStack {
                    Group {
                        switch selectedPage!.name {
                        case .generalSettings:
                            GeneralPreferencesView()
                                .environmentObject(updater)
                        case .themeSettings:
                            ThemePreferencesView()
                        case .textEditingSettings:
                            TextEditingPreferencesView()
                        case .terminalSettings:
                            TerminalPreferencesView()
                        case .sourceControlSettings:
                            SourceControlPreferencesView()
                        case .locationSettings:
                            LocationsPreferencesView()
                        default:
                            Text("Implementation Needed")
                        }
                    }
                }
                .padding(20)
                .frame(
                      minWidth: 0,
                      maxWidth: .infinity,
                      minHeight: 0,
                      maxHeight: .infinity,
                      alignment: .leading
                )
            }
            .navigationSplitViewColumnWidth(500)
        }
        .searchable(text: $filter, placement: .sidebar)
        .navigationTitle(selectedPage?.nameString ?? "Error: selection")
        .frame(width: 1200, height: 750)
        .opacity(hidden ? 1 : 0)
    }
}
