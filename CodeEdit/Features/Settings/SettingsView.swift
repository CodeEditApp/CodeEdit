//
//  SettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import CodeEditSymbols
import AppKit
import Introspect

/// A struct for settings
struct SettingsView: View {
    @StateObject var model = SettingsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var settings: Settings = .shared

    /// An array of navigationItems
    private static let pages: [SettingsPage] = [
        .init(
            .general,
            baseColor: .gray,
            icon: .system("gear"),
            childrenSettings: SettingsData().propertiesOf(SettingsData().general)
        ),
        .init(.accounts, baseColor: .blue, icon: .system("at"), childrenSettings: SettingsData().propertiesOf(SettingsData().accounts)),
//        .init(.behaviors, baseColor: .red, icon: .system("flowchart.fill")),
//        .init(.navigation, baseColor: .green, icon: .system("arrow.triangle.turn.up.right.diamond.fill")),
        .init(
            .theme,
            baseColor: .pink,
            icon: .system("paintbrush.fill"),
            childrenSettings: SettingsData().propertiesOf(SettingsData().theme)
        ),
        .init(
            .textEditing,
            baseColor: .blue,
            icon: .system("pencil.line"),
            childrenSettings: SettingsData().propertiesOf(SettingsData().textEditing)
        ),
        .init(
            .terminal,
            baseColor: .blue,
            icon: .system("terminal.fill"),
            childrenSettings: SettingsData().propertiesOf(SettingsData().terminal)
        ),
//        .init(.keybindings, baseColor: .gray, icon: .system("keyboard.fill")),
        .init(
            .sourceControl,
            baseColor: .blue,
            icon: .symbol("vault"),
            childrenSettings: SettingsData().propertiesOf(SettingsData().sourceControl)
        ),
//        .init(.components, baseColor: .blue, icon: .system("puzzlepiece.fill")),
        .init(
            .location,
            baseColor: .green,
            icon: .system("externaldrive.fill")
        )
//        .init(.advanced, baseColor: .gray, icon: .system("gearshape.2.fill"))
    ]

    /// Variables for the selected Page, the current search text and software updater
    @State private var selectedPage = pages.first!
    @State private var searchText: String = ""

    @Environment(\.presentationMode) var presentationMode

    let updater: SoftwareUpdater

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedPage) {
                Section {
                    ForEach(Self.pages) { item in
                        let lowercasedSearchText: String = searchText.lowercased()
                        if !searchText.isEmpty {
                            SettingsPageView(item)

                            ForEach(item.childrenSettings) { setting in
                                if setting.nameString.lowercased().contains(lowercasedSearchText) {
                                    NavigationLink(value: item) {
                                        Text("    \(setting.nameString.capitalized)")
                                    }
                                }
                            }
                        } else {
                            SettingsPageView(item)
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(215)
            .safeAreaInset(edge: .top, spacing: 0) {
                List {}
                    .frame(height: 35)
                    .searchable(text: $searchText, placement: .sidebar, prompt: "Search")
                    .scrollDisabled(true)
            }
        } detail: {
            Group {
                switch selectedPage.name {
                case .general:
                    GeneralSettingsView().environmentObject(updater)
                case .accounts:
                    AccountsSettingsView()
                case .theme:
                    ThemeSettingsView()
                case .textEditing:
                    TextEditingSettingsView()
                case .terminal:
                    TerminalSettingsView()
                case .sourceControl:
                    SourceControlSettingsView()
                case .location:
                    LocationsSettingsView()
                default:
                    Text("Implementation Needed").frame(alignment: .center)
                }
            }
            .navigationSplitViewColumnWidth(500)
            .hideSidebarToggle()
            .onAppear {
                model.backButtonVisible = false
            }
        }
        .navigationTitle(selectedPage.name.rawValue)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                if !model.backButtonVisible {
                    Rectangle()
                        .frame(width: 10)
                        .opacity(0)
                } else {
                    EmptyView()
                }
            }
        }
        .environmentObject(model)
    }
}

class SettingsViewModel: ObservableObject {
    @Published var backButtonVisible: Bool = false
    @Published var scrolledToTop: Bool = false
}
