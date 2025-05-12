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
                    HStack(spacing: 10) {
                        SearchField("Search", text: $themeSearchQuery)

                        Button {
                            // As discussed, the expected behavior is to duplicate the selected theme.
                            if let selectedTheme = themeModel.selectedTheme {
                                if let fileURL = selectedTheme.fileURL {
                                    themeModel.duplicate(fileURL)
                                }
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        .disabled(themeModel.selectedTheme == nil)
                        .help("Create a new Theme")

                        MenuWithButtonStyle(systemImage: "ellipsis", menu: {
                            Group {
                                Button {
                                    themeModel.importTheme()
                                } label: {
                                    Text("Import Theme...")
                                }
                                Button {
                                    themeModel.exportAllCustomThemes()
                                } label: {
                                    Text("Export All Custom Themes...")
                                }
                                .disabled(themeModel.themes.filter { !$0.isBundled }.isEmpty)
                            }
                        })
                        .padding(.horizontal, 5)
                        .help("Import or Export Custom Themes")
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
                            if let themeIndex = themeModel.themes.firstIndex(of: theme) {
                                Divider().padding(.horizontal, 10)
                                ThemeSettingsThemeRow(
                                    theme: $themeModel.themes[themeIndex],
                                    active: themeModel.getThemeActive(theme)
                                ).id(theme)
                            }
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
                .sheet(isPresented: $themeModel.detailsIsPresented, onDismiss: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        themeModel.isAdding = false
                    }
                }, content: {
                    if let theme = themeModel.detailsTheme, let index = themeModel.themes.firstIndex(where: {
                        $0.fileURL?.absoluteString == theme.fileURL?.absoluteString
                    }) {
                        ThemeSettingsThemeDetails(theme: Binding(
                            get: { themeModel.themes[index] },
                            set: { newValue in
                                if themeModel.detailsIsPresented {
                                    themeModel.themes[index] = newValue
                                    themeModel.save(newValue)
                                    if settings.selectedTheme == theme.name {
                                        themeModel.activateTheme(newValue)
                                    }
                                }
                            }
                        ))
                    }
                })
                .onAppear {
                    updateFilteredThemes()
                }
                .onChange(of: themeSearchQuery) { _ in
                    updateFilteredThemes()
                }
                .onChange(of: themeModel.themes) { _ in
                    updateFilteredThemes()
                }
                .onChange(of: colorScheme) { newColorScheme in
                    updateFilteredThemes(overrideColorScheme: newColorScheme)
                }
            }
        }
    }

    /// Sorts themes by `colorScheme` and `themeSearchQuery`.
    /// Dark mode themes appear before light themes if in dark mode, and vice versa.
    private func updateFilteredThemes(overrideColorScheme: ColorScheme? = nil) {
        // This check is necessary because, when calling `updateFilteredThemes` from within the
        // `onChange` handler that monitors the `colorScheme`, there are cases where the function
        // is invoked with outdated values of `colorScheme`.
        let isDarkScheme = overrideColorScheme ?? colorScheme == .dark

        let themes: [Theme] = isDarkScheme
        ? (themeModel.darkThemes + themeModel.lightThemes)
        : (themeModel.lightThemes + themeModel.darkThemes)

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
