//
//  ThemeModel.swift
//  CodeEditModules/AppPreferences
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
public final class ThemeModel: ObservableObject {

    public static let shared: ThemeModel = .init()

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base folder url `~/Library/Application Support/CodeEdit/`
    private var baseURL: URL {
        filemanager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/CodeEdit")
    }

    /// The URL of the `themes` folder
    internal var themesURL: URL {
        baseURL.appendingPathComponent("themes", isDirectory: true)
    }

    /// Selected 'light' theme
    /// Used for auto-switching theme to match macOS system appearance
    @Published
    public var selectedLightTheme: Theme? {
        didSet {
            AppPreferencesModel.shared.preferences.theme.selectedLightTheme = selectedLightTheme?.name ?? "Broken"
        }
    }

    /// Selected 'dark' theme
    /// Used for auto-switching theme to match macOS system appearance
    @Published
    public var selectedDarkTheme: Theme? {
        didSet {
            AppPreferencesModel.shared.preferences.theme.selectedDarkTheme = selectedDarkTheme?.name ?? "Broken"
        }
    }

    /// The selected appearance in the sidebar.
    /// - **0**: dark mode themes
    /// - **1**: light mode themes
    @Published
    var selectedAppearance: Int = 0

    /// The selected tab in the main section.
    /// - **0**: Preview
    /// - **1**: Editor
    /// - **2**: Terminal
    @Published
    var selectedTab: Int = 1

    /// An array of loaded ``Theme``.
    @Published
    public var themes: [Theme] = [] {
        didSet {
            saveThemes()
            objectWillChange.send()
        }
    }

    /// The currently selected ``Theme``.
    @Published
    public var selectedTheme: Theme? {
        didSet {
            AppPreferencesModel.shared.preferences.theme.selectedTheme = selectedTheme?.name
            updateAppearanceTheme()
        }
    }

    /// Only themes where ``Theme/appearance`` == ``Theme/ThemeType/dark``
    public var darkThemes: [Theme] {
        themes.filter { $0.appearance == .dark }
    }

    /// Only themes where ``Theme/appearance`` == ``Theme/ThemeType/light``
    public var lightThemes: [Theme] {
        themes.filter { $0.appearance == .light }
    }

    private init() {
        do {
            try loadThemes()
        } catch {
            print(error)
        }
    }

    /// Loads a theme from a given url and appends it to ``themes``.
    /// - Parameter url: The URL of the theme
    /// - Returns: A ``Theme``
    private func load(from url: URL) throws -> Theme? {
        do {
            // get the data from the provided file
            let json = try Data(contentsOf: url)
            // decode the json into ``Theme``
            let theme = try JSONDecoder().decode(Theme.self, from: json)
            return theme
        } catch {
            try filemanager.removeItem(at: url)
            return nil
        }
    }

    /// Loads all available themes from `~/Library/Application Support/CodeEdit/themes/`
    ///
    /// If no themes are available, it will create a default theme and save
    /// it to the location mentioned above.
    ///
    /// When overrides are found in `~/Library/Application Support/CodeEdit/.preferences.json`
    /// they are applied to the loaded themes without altering the original
    /// the files in `~/Library/Application Support/CodeEdit/themes/`.
    public func loadThemes() throws {
        // remove all themes from memory
        themes.removeAll()

        let url = themesURL

        var isDir: ObjCBool = false

        // check if a themes directory exists, otherwise create one
        if !filemanager.fileExists(atPath: url.path, isDirectory: &isDir) {
            try filemanager.createDirectory(at: url, withIntermediateDirectories: true)
        }

        try loadBundledThemes()

        // get all filenames in themes folder that end with `.json`
        let content = try filemanager.contentsOfDirectory(atPath: url.path).filter { $0.contains(".json") }

        let prefs = AppPreferencesModel.shared.preferences
        // load each theme from disk
        try content.forEach { file in
            let fileURL = url.appendingPathComponent(file)
            if var theme = try load(from: fileURL) {

                // get all properties of terminal and editor colors
                guard let terminalColors = try theme.terminal.allProperties() as? [String: Theme.Attributes],
                      let editorColors = try theme.editor.allProperties() as? [String: Theme.Attributes]
                else {
                    print("error")
                    throw NSError()
                }

                // check if there are any overrides in `preferences.json`
                if let overrides = prefs.theme.overrides[theme.name]?["terminal"] {
                    terminalColors.forEach { (key, _) in
                        if let attributes = overrides[key] {
                            theme.terminal[key] = attributes
                        }
                    }
                }
                if let overrides = prefs.theme.overrides[theme.name]?["editor"] {
                    editorColors.forEach { (key, _) in
                        if let attributes = overrides[key] {
                            theme.editor[key] = attributes
                        }
                    }
                }

                // add the theme to themes array
                self.themes.append(theme)

                // if there already is a selected theme in `preferences.json` select this theme
                // otherwise take the first in the list
                self.selectedDarkTheme = self.darkThemes.first {
                    $0.name == prefs.theme.selectedDarkTheme
                } ?? self.darkThemes.first

                self.selectedLightTheme = self.lightThemes.first {
                    $0.name == prefs.theme.selectedLightTheme
                } ?? self.lightThemes.first

                // For selecting the default theme, doing it correctly on startup requires some more logic
                let userSelectedTheme = self.themes.first { $0.name == prefs.theme.selectedTheme }
                let systemAppearance = NSAppearance.currentDrawing().name
                if userSelectedTheme != nil {
                    self.selectedTheme = userSelectedTheme
                } else {
                    if systemAppearance == .darkAqua {
                        self.selectedTheme = self.selectedDarkTheme
                    } else {
                        self.selectedTheme = self.selectedLightTheme
                    }
                }
            }
        }
    }

    /// This function stores  'dark' and 'light' themes into `ThemePreferences` if user happens to select a theme
    private func updateAppearanceTheme() {
        if self.selectedTheme?.appearance == .dark {
            self.selectedDarkTheme = self.selectedTheme
        } else if self.selectedTheme?.appearance == .light {
            self.selectedLightTheme = self.selectedTheme
        }
    }

    private func loadBundledThemes() throws {
        let bundledThemeNames: [String] = [
            "codeedit-xcode-dark",
            "codeedit-xcode-light",
            "codeedit-github-dark",
            "codeedit-github-light",
            "codeedit-midnight"
        ]
        for themeName in bundledThemeNames {
            guard let defaultUrl = Bundle.main.url(forResource: themeName, withExtension: "json") else {
                return
            }
            let json = try Data(contentsOf: defaultUrl)
            let jsonObject = try JSONSerialization.jsonObject(with: json)
            let prettyJSON = try JSONSerialization.data(withJSONObject: jsonObject,
                                                        options: .prettyPrinted)

            try prettyJSON.write(to: themesURL.appendingPathComponent("\(themeName).json"), options: .atomic)
        }
    }

    /// Removes all overrides of the given theme in
    /// `~/Library/Application Support/CodeEdit/preferences.json`
    ///
    /// After removing overrides, themes are reloaded
    /// from `~/Library/Application Support/CodeEdit/themes`. See ``loadThemes()``
    /// for more information.
    ///
    /// - Parameter theme: The theme to reset
    public func reset(_ theme: Theme) {
        AppPreferencesModel.shared.preferences.theme.overrides[theme.name] = [:]
        do {
            try self.loadThemes()
        } catch {
            print(error)
        }
    }

    /// Removes the given theme from `–/Library/Application Support/CodeEdit/themes`
    ///
    /// After removing the theme, themes are reloaded
    /// from `~/Library/Application Support/CodeEdit/themes`. See ``loadThemes()``
    /// for more information.
    ///
    /// - Parameter theme: The theme to delete
    public func delete(_ theme: Theme) {
        let url = themesURL
            .appendingPathComponent(theme.name)
            .appendingPathExtension("json")
        do {
            // remove the theme from the list
            try filemanager.removeItem(at: url)

            // remove from overrides in `preferences.json`
            AppPreferencesModel.shared.preferences.theme.overrides.removeValue(forKey: theme.name)

            // reload themes
            try self.loadThemes()
        } catch {
            print(error)
        }
    }

    /// Saves changes on theme properties to `overrides`
    /// in `~/Library/Application Support/CodeEdit/preferences.json`.
    private func saveThemes() {
        let url = themesURL
        themes.forEach { theme in
            do {
                // load the original theme from `~/Library/Application Support/CodeEdit/themes/`
                let originalUrl = url.appendingPathComponent(theme.name).appendingPathExtension("json")
                let originalData = try Data(contentsOf: originalUrl)
                let originalTheme = try JSONDecoder().decode(Theme.self, from: originalData)

                // get properties of the current theme as well as the original
                guard let terminalColors = try theme.terminal.allProperties() as? [String: Theme.Attributes],
                      let editorColors = try theme.editor.allProperties() as? [String: Theme.Attributes],
                      let oTermColors = try originalTheme.terminal.allProperties() as? [String: Theme.Attributes],
                      let oEditColors = try originalTheme.editor.allProperties() as? [String: Theme.Attributes]
                else {
                    throw NSError()
                }

                // compare the properties and if there are differences, save to overrides
                // in `preferences.json
                var newAttr: [String: [String: Theme.Attributes]] = ["terminal": [:], "editor": [:]]
                terminalColors.forEach { (key, value) in
                    if value != oTermColors[key] {
                        newAttr["terminal"]?[key] = value
                    }
                }

                editorColors.forEach { (key, value) in
                    if value != oEditColors[key] {
                        newAttr["editor"]?[key] = value
                    }
                }
                AppPreferencesModel.shared.preferences.theme.overrides[theme.name] = newAttr

            } catch {
                print(error)
            }
        }
    }
}
