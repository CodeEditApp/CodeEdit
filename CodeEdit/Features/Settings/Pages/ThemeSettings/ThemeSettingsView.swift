//
//  ThemePreferencesView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import Preferences

/// A view that implements the `Theme` preference section
struct ThemeSettingsView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @ObservedObject
    private var themeModel: ThemeModel = .shared

    @ObservedObject
    private var prefs: SettingsModel = .shared

    @State
    private var listView: Bool = false

    @State
    private var selectedAppearance: ThemeSettingsAppearances = .dark

    enum ThemeSettingsAppearances: String, CaseIterable {
        case light = "Light Appearance"
        case dark = "Dark Appearance"
    }

    var body: some View {
        SettingsForm {
            Section {
                changeThemeOnSystemAppearance
                useThemeBackground
            }
            Section("Editor Theme") {
                VStack(spacing: 0) {
                    if prefs.preferences.theme.mirrorSystemAppearance {
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
                                active: themeModel.selectedTheme == theme,
                                action: { themeModel.selectedTheme = theme }
                            ).id(theme)
                        }
                        ForEach(selectedAppearance == .dark ? themeModel.lightThemes : themeModel.darkThemes) { theme in
                            Divider()
                            ThemeSettingsThemeRow(
                                theme: $themeModel.themes[themeModel.themes.firstIndex(of: theme)!],
                                active: themeModel.selectedTheme == theme,
                                action: { themeModel.selectedTheme = theme }
                            ).id(theme)
                        }
                    }
                }
                .padding(-10)
            }
            Section("Terminal Theme") {
                Toggle("Use editor theme", isOn: $prefs.preferences.terminal.useEditorTheme)
                Toggle("Always use dark terminal appearance", isOn: $prefs.preferences.terminal.darkAppearance)
            }
            if !prefs.preferences.terminal.useEditorTheme {
                Section {
                    VStack(spacing: 0) {
                        if prefs.preferences.theme.mirrorSystemAppearance
                            && !prefs.preferences.terminal.darkAppearance {
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
                            ForEach(
                                selectedAppearance == .dark || prefs.preferences.terminal.darkAppearance
                                ? themeModel.darkThemes
                                : themeModel.lightThemes
                            ) { theme in
                                Divider()
                                ThemeSettingsThemeRow(
                                    theme: $themeModel.themes[themeModel.themes.firstIndex(of: theme)!],
                                    active: themeModel.selectedTheme == theme,
                                    action: { themeModel.selectedTheme = theme }
                                ).id(theme)
                            }
                            if !prefs.preferences.terminal.darkAppearance {
                                ForEach(
                                    selectedAppearance == .dark
                                    ? themeModel.lightThemes
                                    : themeModel.darkThemes
                                ) { theme in
                                    Divider()
                                    ThemeSettingsThemeRow(
                                        theme: $themeModel.themes[themeModel.themes.firstIndex(of: theme)!],
                                        active: themeModel.selectedTheme == theme,
                                        action: { themeModel.selectedTheme = theme }
                                    ).id(theme)
                                }
                            }
                        }
                    }
                    .padding(-10)
                }
            }
        }
    }
}

private extension ThemeSettingsView {
    private var useThemeBackground: some View {
        Toggle("Use theme background ", isOn: $prefs.preferences.theme.useThemeBackground)
    }

    private var changeThemeOnSystemAppearance: some View {
        Toggle(
            "Automatically change theme based on system appearance",
            isOn: $prefs.preferences.theme.mirrorSystemAppearance
        )
        .onChange(of: prefs.preferences.theme.mirrorSystemAppearance) { value in
            if value {
                if colorScheme == .dark {
                    themeModel.selectedTheme = themeModel.selectedDarkTheme
                } else {
                    themeModel.selectedTheme = themeModel.selectedLightTheme
                }
            } else {
                themeModel.selectedTheme = themeModel.themes.first {
                    $0.name == prefs.preferences.theme.selectedTheme
                }
            }
        }
    }
}
