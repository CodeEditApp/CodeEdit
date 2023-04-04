//
//  ThemePreferencesView.swift
//  CodeEdit
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import Preferences

/// A view that implements the `Theme` settings page
struct ThemeSettingsView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @ObservedObject
    private var themeModel: ThemeModel = .shared

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var listView: Bool = false

    @State
    private var selectedAppearance: ThemeSettingsAppearances = .dark

    enum ThemeSettingsAppearances: String, CaseIterable {
        case light = "Light Appearance"
        case dark = "Dark Appearance"
    }

    var body: some View {
        Form {
            Section {
                terminalThemeOptions
            }
            Section("Editor Theme") {
                editorTheme
            }
            terminalThemeOptions
            if !prefs.preferences.terminal.useEditorTheme {
                Section {
                    terminalTheme
                }
            }
        }
        .formStyle(.grouped)
    }
}

private extension ThemeSettingsView {
    // MARK: - Sections

    private var editorTheme: some View {
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

    private var terminalTheme: some View {
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

    private var terminalThemeOptions: some View {
        Section("Terminal Theme") {
            useEditorThemeToggle
            alwaysUseDarkTerminalAppearanceToggle
        }
    }

    // MARK: - Preference Views

    private var alwaysUseDarkTerminalAppearanceToggle: some View {
        Toggle("Always use dark terminal appearance", isOn: $prefs.preferences.terminal.darkAppearance)
    }

    private var useEditorThemeToggle: some View {
        Toggle("Use editor theme", isOn: $prefs.preferences.terminal.useEditorTheme)
    }

    private var useThemeBackgroundToggle: some View {
        Toggle("Use theme background ", isOn: $prefs.preferences.theme.useThemeBackground)
    }

    private var changeThemeOnSystemAppearanceToggle: some View {
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
