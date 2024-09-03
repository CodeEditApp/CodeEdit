//
//  ThemePreferencesView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI

/// A view that implements the `Theme` preference section
struct ThemeSettingsView: View {
    @Environment(\.colorScheme)
    var colorScheme
    @ObservedObject private var themeModel: ThemeModel = .shared
    @AppSettings(\.theme)
    var settings
    @AppSettings(\.terminal.darkAppearance)
    var useDarkTerminalAppearance

    @State private var listView: Bool = false
    @State private var themeSearchQuery: String = ""
    @State private var filteredThemes: [Theme] = []

    var body: some View {
        VStack {
            SettingsForm {
                Section {
                    HStack {
                        SearchField("Search", text: $themeSearchQuery)

                        Button {

                        } label: {
                            Image(systemName: "plus")
                        }

                        Button {

                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }
                if themeSearchQuery.isEmpty {
                    Section {
                        changeThemeOnSystemAppearance
                        if settings.matchAppearance {
                            alwaysUseDarkTerminalAppearance
                        }
                        useThemeBackground
                    }
                }

                Section {
                    VStack(spacing: 0) {
                        ForEach(filteredThemes) { theme in
                            Divider().padding(.horizontal, 10)
                            ThemeSettingsThemeRow(
                                theme: $themeModel.themes[themeModel.themes.firstIndex(of: theme)!],
                                active: themeModel.getThemeActive(theme)
                            ).id(theme)
                        }
                    }
                    .padding(-10)
                } footer: {
                    HStack {
                        Spacer()
                        Button("Import...") {
                            themeModel.importTheme()
                        }
                    }
                    .padding(.top, 10)
                }
                .sheet(item: $themeModel.detailsTheme) {
                    themeModel.isAdding = false
                } content: { theme in
                    if let index = themeModel.themes.firstIndex(where: {
                        $0.fileURL?.absoluteString == theme.fileURL?.absoluteString
                    }) {
                        ThemeSettingsThemeDetails(theme: Binding(
                            get: { themeModel.themes[index] },
                            set: { newValue in
                                themeModel.themes[index] = newValue
                                themeModel.save(newValue)
                                if settings.selectedTheme == theme.name {
                                    themeModel.activateTheme(newValue)
                                }
                            }
                        ))
                    }
                }
                .onAppear {
                    updateFilteredThemes()
                }
                .onChange(of: themeSearchQuery) { _ in
                    updateFilteredThemes()
                }
                .onChange(of: themeModel.selectedAppearance) { _ in
                    updateFilteredThemes()
                }

            }
        }
    }

    private func updateFilteredThemes() {
        var themes: [Theme] = if themeModel.selectedAppearance == .dark {
            themeModel.darkThemes + themeModel.lightThemes
        } else {
            themeModel.lightThemes + themeModel.darkThemes
        }

        Task {
            filteredThemes = themeSearchQuery.isEmpty ? themes : await filterAndSortThemes(themes)
        }
    }

    private func filterAndSortThemes(_ themes: [Theme]) async -> [Theme] {
        return await themes.fuzzySearch(query: themeSearchQuery).map { $1 }
    }
}

private extension ThemeSettingsView {
    private var useThemeBackground: some View {
        Toggle("Use theme background ", isOn: $settings.useThemeBackground)
    }

    private var alwaysUseDarkTerminalAppearance: some View {
        Toggle("Always use dark terminal appearance", isOn: $useDarkTerminalAppearance)
    }

    private var changeThemeOnSystemAppearance: some View {
        Toggle(
            "Automatically change theme based on system appearance",
            isOn: $settings.matchAppearance
        )
        .onChange(of: settings.matchAppearance) { value in
            if value {
                if colorScheme == .dark {
                    themeModel.selectedTheme = themeModel.selectedDarkTheme
                } else {
                    themeModel.selectedTheme = themeModel.selectedLightTheme
                }
            } else {
                themeModel.selectedTheme = themeModel.themes.first {
                    $0.name == settings.selectedTheme
                }
            }
        }
    }
}
