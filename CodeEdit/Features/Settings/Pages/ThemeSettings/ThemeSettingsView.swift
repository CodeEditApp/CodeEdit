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
    @State private var selectedAppearance: ThemeSettingsAppearances = .dark

    enum ThemeSettingsAppearances: String, CaseIterable {
        case light = "Light Appearance"
        case dark = "Dark Appearance"
    }

    func getThemeActive (_ theme: Theme) -> Bool {
        if settings.matchAppearance {
            return selectedAppearance == .dark
            ? themeModel.selectedDarkTheme == theme
            : selectedAppearance == .light
                ? themeModel.selectedLightTheme == theme
                : themeModel.selectedTheme == theme
        }
        return themeModel.selectedTheme == theme
    }

    func activateTheme (_ theme: Theme) {
        if settings.matchAppearance {
            if selectedAppearance == .dark {
                themeModel.selectedDarkTheme = theme
            } else if selectedAppearance == .light {
                themeModel.selectedLightTheme = theme
            }
            if (selectedAppearance == .dark && colorScheme == .dark)
                || (selectedAppearance == .light && colorScheme == .light) {
                themeModel.selectedTheme = theme
            }
        } else {
            themeModel.selectedTheme = theme
            if colorScheme == .light {
                themeModel.selectedLightTheme = theme
            }
            if colorScheme == .dark {
                themeModel.selectedDarkTheme = theme
            }
        }
    }

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
                        Picker("", selection: $selectedAppearance) {
                            ForEach(ThemeSettingsAppearances.allCases, id: \.self) { tab in
                                Text(tab.rawValue)
                                    .tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .padding(10)
                    }
                    VStack(spacing: 0) {
                        ForEach(selectedAppearance == .dark ? themeModel.darkThemes : themeModel.lightThemes) { theme in
                            Divider()
                            ThemeSettingsThemeRow(
                                theme: $themeModel.themes[themeModel.themes.firstIndex(of: theme)!],
                                active: getThemeActive(theme),
                                action: activateTheme
                            ).id(theme)
                        }
                        ForEach(selectedAppearance == .dark ? themeModel.lightThemes : themeModel.darkThemes) { theme in
                            Divider()
                            ThemeSettingsThemeRow(
                                theme: $themeModel.themes[themeModel.themes.firstIndex(of: theme)!],
                                active: getThemeActive(theme),
                                action: activateTheme
                            ).id(theme)
                        }
                    }
                }
                .padding(-10)
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
