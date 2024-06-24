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

    var body: some View {
        SettingsForm {
            Section {
                changeThemeOnSystemAppearance
                if settings.matchAppearance {
                    alwaysUseDarkTerminalAppearance
                }
                useThemeBackground
            }
            Section {
                VStack(spacing: 0) {
                    if settings.matchAppearance {
                        Picker("", selection: $themeModel.selectedAppearance) {
                            ForEach(ThemeModel.ThemeSettingsAppearances.allCases, id: \.self) { tab in
                                Text(tab.rawValue)
                                    .tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .padding(10)
                    }
                    VStack(spacing: 0) {
                        ForEach(
                            themeModel.selectedAppearance == .dark
                                ? themeModel.darkThemes
                                : themeModel.lightThemes
                        ) { theme in
                            Divider().padding(.horizontal, 10)
                            ThemeSettingsThemeRow(
                                theme: $themeModel.themes[themeModel.themes.firstIndex(of: theme)!],
                                active: themeModel.getThemeActive(theme)
                            ).id(theme)
                        }
                        ForEach(
                            themeModel.selectedAppearance == .dark
                                ? themeModel.lightThemes
                                : themeModel.darkThemes
                        ) { theme in
                            Divider().padding(.horizontal, 10)
                            ThemeSettingsThemeRow(
                                theme: $themeModel.themes[themeModel.themes.firstIndex(of: theme)!],
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
                    }
                ))
            }

        }
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
