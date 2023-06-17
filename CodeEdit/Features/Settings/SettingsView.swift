//
//  SettingsView.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 26/03/23.
//

import SwiftUI
import CodeEditSymbols

/// A struct for settings
struct SettingsView: View {
    @StateObject var model = SettingsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var count: Int = 1

    /// Variables for the selected Page, the current search text and software updater
    @State private var selectedPage: SettingsPage = .init(.general, baseColor: .gray, icon: .system("gear"))
    @State private var searchText: String = ""

    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var settings: Settings = .shared

    let updater: SoftwareUpdater

    func resultFound(_ page: SettingsPage, pages: [SettingsPage]) -> [SettingsPage] {
        var lowercasedSearchText: String = searchText.lowercased()
        var returnedPages: [SettingsPage] = []

        // swiftlint:disable opening_brace
        for item in pages where
            item.displayName.lowercased().contains(lowercasedSearchText) &&
            item.displayName != "" &&
            item.name == page.name &&
            item.isSetting
        {
            returnedPages.append(item)
        }

        return returnedPages
    }

    func createPageAndSettings(
        _ settingsStruct: Any,
        parent: SettingsPage,
        prePages: [SettingsPage]
    ) -> [SettingsPage] {
        var pages: [SettingsPage] = prePages
        pages.append(parent)

        for setting in SettingsData().propertiesOf(settingsStruct) {
            pages.append(
                SettingsPage(
                    parent.name,
                    baseColor: parent.baseColor,
                    icon: parent.icon,
                    isSetting: true,
                    displayName: setting.nameString
                )
            )
        }

        return pages
    }

    private func populatePages() -> [SettingsPage] {
        var pages: [SettingsPage] = []
        let settingsData: SettingsData = SettingsData()

        pages = createPageAndSettings(
            settingsData.general,
            parent: SettingsPage(.general, baseColor: .gray, icon: .system("gear"), isSetting: false),
            prePages: pages
        )
        pages = createPageAndSettings(
            settingsData.accounts,
            parent: SettingsPage(.accounts, baseColor: .blue, icon: .system("at")),
            prePages: pages
        )
        pages = createPageAndSettings(
            settingsData.theme,
            parent: SettingsPage(.theme, baseColor: .pink, icon: .system("paintbrush.fill")),
            prePages: pages
        )
        pages = createPageAndSettings(
            settingsData.textEditing,
            parent: SettingsPage(.textEditing, baseColor: .blue, icon: .system("pencil.line")),
            prePages: pages
        )
        pages = createPageAndSettings(
            settingsData.terminal,
            parent: SettingsPage(.terminal, baseColor: .blue, icon: .system("terminal.fill")),
            prePages: pages
        )
        pages = createPageAndSettings(
            settingsData.sourceControl,
            parent: SettingsPage(.sourceControl, baseColor: .blue, icon: .symbol("vault")),
            prePages: pages
        )
        pages.append(SettingsPage(.location, baseColor: .green, icon: .system("externaldrive.fill")))

        return pages
    }

    var body: some View {
        let pages: [SettingsPage] = populatePages()
        NavigationSplitView {
            List(selection: $selectedPage) {
                Section {
                    ForEach(pages) { page in
                        let results = resultFound(page, pages: pages)
                        if !results.isEmpty && !page.isSetting {
                            if !page.isSetting {
                                SettingsPageView(page)
                            }

                            ForEach(results, id: \.displayName) { setting in
                                if setting.displayName.lowercased().contains(searchText.lowercased()) {
                                    NavigationLink(value: setting) {
                                        setting.displayName.capitalized.highlightOccurrences(searchText)
                                            .padding(.leading, 22.5)
                                    }
                                }
                            }
                        } else if !page.isSetting {
                            SettingsPageView(page)
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
// swiftlint:enable opening_brace
