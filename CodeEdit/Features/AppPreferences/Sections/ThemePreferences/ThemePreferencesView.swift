//
//  ThemePreferencesView.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 30.03.22.
//

import SwiftUI
import Preferences

/// A view that implements the `Theme` preference section
struct ThemePreferencesView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @ObservedObject
    private var themeModel: ThemeModel = .shared

    @ObservedObject
    private var prefs: AppPreferencesModel = .shared

    @State
    private var listView: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            frame
            HStack(alignment: .center) {
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

                Spacer()
                Button("Get More Themes...") {}
                    .disabled(true)
                    .help("Not yet implemented")
                HelpButton {}
                    .disabled(true)
                    .help("Not yet implemented")
            }
        }
        .frame(width: 872)
        .padding()
        .onAppear {
            try? themeModel.loadThemes()
        }
    }

    private var frame: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 1) {
                sidebar
                settingsContent
            }
            .padding(1)
            .background(Rectangle().foregroundColor(Color(NSColor.separatorColor)))
            .frame(height: 468)
        }
    }

    private var sidebar: some View {
        VStack(spacing: 1) {
            PreferencesToolbar {
                let options = [
                    "Dark Mode",
                    "Light Mode"
                ]
                SegmentedControl($themeModel.selectedAppearance, options: options)
            }
            if listView {
                sidebarListView
            } else {
                sidebarScrollView
            }
            PreferencesToolbar {
                sidebarBottomToolbar
            }
        }
        .frame(width: 320)
    }

    private var sidebarListView: some View {
        List(selection: $themeModel.selectedTheme) {
            ForEach(themeModel.selectedAppearance == 0 ? themeModel.darkThemes : themeModel.lightThemes) { theme in
                Button(theme.displayName) { themeModel.selectedTheme = theme }
                    .buttonStyle(.plain)
                    .tag(theme)
                    .contextMenu {
                        Button("Reset Theme") {
                            themeModel.reset(theme)
                        }
                        Divider()
                        Button("Delete Theme", role: .destructive) {
                            themeModel.delete(theme)
                        }
                        .disabled(themeModel.themes.count <= 1)
                    }
            }
        }
    }

    private var sidebarScrollView: some View {
        ScrollView {
            let grid: [GridItem] = .init(
                repeating: .init(.fixed(130), spacing: 20, alignment: .center),
                count: 2
            )
            LazyVGrid(columns: grid,
                      alignment: .center,
                      spacing: 20) {
                ForEach(themeModel.selectedAppearance == 0 ? themeModel.darkThemes : themeModel.lightThemes) { theme in
                    ThemePreviewIcon(
                        theme,
                        selection: $themeModel.selectedTheme,
                        colorScheme: themeModel.selectedAppearance == 0 ? .dark : .light
                    )
                    .transition(.opacity)
                    .contextMenu {
                        Button("Reset Theme") {
                            themeModel.reset(theme)
                        }
                        Divider()
                        Button("Delete Theme", role: .destructive) {
                            themeModel.delete(theme)
                        }
                        .disabled(themeModel.themes.count <= 1)
                    }
                }
            }
                      .padding(.vertical, 20)
        }
        .background(EffectView(.contentBackground))
    }

    private var sidebarBottomToolbar: some View {
        HStack {
            Button {} label: {
                Image(systemName: "plus")
            }
            .disabled(true)
            .help("Not yet implemented")
            .buttonStyle(.plain)
            Button {
                themeModel.delete(themeModel.selectedTheme!)
            } label: {
                Image(systemName: "minus")
            }
            .disabled(themeModel.selectedTheme == nil || themeModel.themes.count <= 1)
            .help("Delete selected theme")
            .buttonStyle(.plain)
            Divider()
            Button { try? themeModel.loadThemes() } label: {
                Image(systemName: "arrow.clockwise")
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                listView = true
            } label: {
                Image(systemName: "list.dash")
                    .foregroundColor(listView ? .accentColor : .primary)
            }
            .buttonStyle(.plain)
            Button {
                listView = false
            } label: {
                Image(systemName: "square.grid.2x2")
                    .symbolVariant(listView ? .none : .fill)
                    .foregroundColor(listView ? .primary : .accentColor)
            }
            .buttonStyle(.plain)
        }
    }

    private var settingsContent: some View {
        VStack(spacing: 1) {
            let options = [
                "Preview",
                "Editor",
                "Terminal"
            ]
            PreferencesToolbar {
                SegmentedControl($themeModel.selectedTab, options: options)
            }
            switch themeModel.selectedTab {
            case 1:
                EditorThemeView()
            case 2:
                TerminalThemeView()
            default:
                PreviewThemeView()
            }
            PreferencesToolbar {
                HStack {
                    Spacer()
                    Button {} label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct PrefsThemes_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreferencesView()
            .preferredColorScheme(.light)
    }
}
