//
//  ThemeModel.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI

/// The Theme View Model. Accessible via the singleton "``ThemeModel/shared``".
///
/// **Usage:**
/// ```swift
/// @StateObject
/// private var themeModel: ThemeModel = .shared
/// ```
final class ThemeModel: ObservableObject {
    static let shared: ThemeModel = .init()

    /// Default instance of the `FileManager`
    let filemanager = FileManager.default

    /// The base folder url `~/Library/Application Support/CodeEdit/`
    private var baseURL: URL {
        filemanager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/CodeEdit")
    }

    var bundledThemesURL: URL? {
        Bundle.main.resourceURL?.appendingPathComponent("DefaultThemes", isDirectory: true) ?? nil
    }

    /// The URL of the `Themes` folder
    internal var themesURL: URL {
        baseURL.appendingPathComponent("Themes", isDirectory: true)
    }

    /// The URL of the `Extensions` folder
    internal var extensionsURL: URL {
        baseURL.appendingPathComponent("Extensions", isDirectory: true)
    }

    /// The URL of the `settings.json` file
    internal var settingsURL: URL {
        baseURL.appendingPathComponent("settings.json", isDirectory: true)
    }

    /// Selected 'light' theme
    /// Used for auto-switching theme to match macOS system appearance
    @Published var selectedLightTheme: Theme? {
        didSet {
            DispatchQueue.main.async {
                Settings.shared
                    .preferences.theme.selectedLightTheme = self.selectedLightTheme?.name ?? "Broken"
            }
        }
    }

    /// Selected 'dark' theme
    /// Used for auto-switching theme to match macOS system appearance
    @Published var selectedDarkTheme: Theme? {
        didSet {
            DispatchQueue.main.async {
                Settings.shared
                    .preferences.theme.selectedDarkTheme = self.selectedDarkTheme?.name ?? "Broken"
            }
        }
    }

    @Published var presentingDetails: Bool = false

    @Published var isAdding: Bool = false

    @Published var detailsTheme: Theme? {
        didSet {
            if detailsTheme == nil {
                isAdding = false
            }
        }
    }

    /// The selected appearance in the sidebar.
    /// - **0**: dark mode themes
    /// - **1**: light mode themes
    @Published var selectedAppearance: Int = 0

    /// An array of loaded ``Theme``.
    @Published var themes: [Theme] = []

    /// The currently selected ``Theme``.
    @Published var selectedTheme: Theme? {
        didSet {
            DispatchQueue.main.async {
                Settings[\.theme].selectedTheme = self.selectedTheme?.name
            }
            updateAppearanceTheme()
        }
    }

    /// Only themes where ``Theme/appearance`` == ``Theme/ThemeType/dark``
    var darkThemes: [Theme] {
        themes.filter { $0.appearance == .dark }
    }

    /// Only themes where ``Theme/appearance`` == ``Theme/ThemeType/light``
    var lightThemes: [Theme] {
        themes.filter { $0.appearance == .light }
    }

    private init() {
        do {
            try loadThemes()
        } catch {
            print(error)
        }
    }

    /// This function stores  'dark' and 'light' themes into `ThemePreferences` if user happens to select a theme
    func updateAppearanceTheme() {
        if self.selectedTheme?.appearance == .dark {
            self.selectedDarkTheme = self.selectedTheme
        } else if self.selectedTheme?.appearance == .light {
            self.selectedLightTheme = self.selectedTheme
        }
    }

    func cancelDetails(_ theme: Theme) {
        if let index = themes.firstIndex(where: { $0.fileURL == theme.fileURL }),
        let detailsTheme = self.detailsTheme {
            self.themes[index] = detailsTheme
            self.save(self.themes[index])
        }
    }
}
