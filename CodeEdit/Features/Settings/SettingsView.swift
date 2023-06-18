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

    /// Searches through an array of pages to check if a page name exists in the array
    private func resultFound(_ page: SettingsPage, pages: [SettingsPage]) -> SettingsSearchResult {
        let lowercasedSearchText: String = searchText.lowercased()
        var returnedPages: [SettingsPage] = []
        var foundPage: Bool = false

        for item in pages where item.name == page.name {
            if item.isSetting && item.displayName.lowercased().contains(lowercasedSearchText) {
                returnedPages.append(item)
            } else if item.name.rawValue.contains(lowercasedSearchText) && !item.isSetting {
                print("found page for page:", String(describing: item))
                foundPage = true
            }
        }

        return SettingsSearchResult(pageFound: foundPage, pages: returnedPages)
    }

    /// Creates a SettingsPage and it's respective child settings
    private func createPageAndSettings(
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

    /// Creates all the neccessary pages
    private func populatePages() -> [SettingsPage] {
        var pages: [SettingsPage] = []
        let settingsData: SettingsData = SettingsData()

        pages = createPageAndSettings(
            settingsData.general,
            parent: SettingsPage(.general, baseColor: .gray, icon: .system("gear")),
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
                        if !searchText.isEmpty {
                            let results: SettingsSearchResult = resultFound(page, pages: pages)

                            if !results.pages.isEmpty && !page.isSetting {
                                SettingsPageView(page, searchText: searchText)

                                ForEach(results.pages, id: \.displayName) { setting in
                                    NavigationLink(value: setting) {
                                        setting.displayName.capitalized.highlightOccurrences(searchText)
                                            .padding(.leading, 22.5)
                                    }
                                }
                            } else if
                                page.name.rawValue.lowercased().contains(searchText.lowercased()) &&
                                !page.isSetting
                            {
                                SettingsPageView(page, searchText: searchText)
                            }
                        } else if !page.isSetting {
                            SettingsPageView(page, searchText: searchText)
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
