//
//  ThemeModel.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI
import UniformTypeIdentifiers

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
    private let filemanager = FileManager.default

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

    @Published var detailsTheme: Theme?

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
            print(error)
            return nil
        }
    }

    /// Loads all available themes from `~/Library/Application Support/CodeEdit/Themes/`
    ///
    /// If no themes are available, it will create a default theme and save
    /// it to the location mentioned above.
    ///
    /// When overrides are found in `~/Library/Application Support/CodeEdit/settings.json`
    /// they are applied to the loaded themes without altering the original
    /// the files in `~/Library/Application Support/CodeEdit/Themes/`.
    func loadThemes() throws { // swiftlint:disable:this function_body_length
        if let bundledThemesURL = bundledThemesURL {
            // remove all themes from memory
            themes.removeAll()

            var isDir: ObjCBool = false

            // check if a themes directory exists, otherwise create one
            if !filemanager.fileExists(atPath: themesURL.path, isDirectory: &isDir) {
                try filemanager.createDirectory(at: themesURL, withIntermediateDirectories: true)
            }

            // get all URLs in users themes folder that end with `.cetheme`
            let userDefinedThemeFilenames = try filemanager.contentsOfDirectory(atPath: themesURL.path).filter {
                $0.contains(".cetheme")
            }
            let userDefinedThemeURLs = userDefinedThemeFilenames.map {
                themesURL.appendingPathComponent($0)
            }

            // get all bundled theme URLs
            let bundledThemeFilenames = try filemanager.contentsOfDirectory(atPath: bundledThemesURL.path).filter {
                $0.contains(".cetheme")
            }
            let bundledThemeURLs = bundledThemeFilenames.map {
                bundledThemesURL.appendingPathComponent($0)
            }

            // combine user theme URLs with bundled theme URLs
            let themeURLs = userDefinedThemeURLs + bundledThemeURLs

            let prefs = Settings.shared.preferences

            // load each theme from disk and store in memory
            try themeURLs.forEach { fileURL in
                if var theme = try load(from: fileURL) {

                    // get all properties of terminal and editor colors
                    guard let terminalColors = try theme.terminal.allProperties() as? [String: Theme.Attributes],
                          let editorColors = try theme.editor.allProperties() as? [String: Theme.Attributes]
                    else {
                        print("error")
                        // TODO: Throw a proper error
                        throw NSError() // swiftlint:disable:this discouraged_direct_init
                    }

                    // check if there are any overrides in `settings.json`
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

                    theme.isBundled = fileURL.path.contains(bundledThemesURL.path)

                    theme.fileURL = fileURL

                    // add the theme to themes array
                    self.themes.append(theme)

                    // if there already is a selected theme in `settings.json` select this theme
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
    }

    /// This function stores  'dark' and 'light' themes into `ThemePreferences` if user happens to select a theme
    private func updateAppearanceTheme() {
        if self.selectedTheme?.appearance == .dark {
            self.selectedDarkTheme = self.selectedTheme
        } else if self.selectedTheme?.appearance == .light {
            self.selectedLightTheme = self.selectedTheme
        }
    }

    /// Removes the given theme from `–/Library/Application Support/CodeEdit/themes`
    ///
    /// After removing the theme, themes are reloaded
    /// from `~/Library/Application Support/CodeEdit/Themes`. See ``loadThemes()``
    /// for more information.
    ///
    /// - Parameter theme: The theme to delete
    func delete(_ theme: Theme) {
        if let url = theme.fileURL {
            do {
                // remove the theme from the list
                try filemanager.removeItem(at: url)

                // remove from overrides in `settings.json`
                Settings.shared.preferences.theme.overrides.removeValue(forKey: theme.name)

                // reload themes
                try self.loadThemes()
            } catch {
                print(error)
            }
        }
    }

    func importTheme() {
        let openPanel = NSOpenPanel()
        let allowedTypes = [UTType(filenameExtension: "cetheme")!]

        openPanel.prompt = "Import"
        openPanel.allowedContentTypes = allowedTypes
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false

        openPanel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let url = openPanel.urls.first {
                    self.duplicate(url)
                }
            }
        }
    }

    func rename(to newName: String, theme: Theme) {
        do {
            guard let oldURL = theme.fileURL else {
                throw NSError(
                    domain: "ThemeModel",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Theme file URL not found"]
                )
            }

            var iterator = 1
            var finalName = newName
            var finalURL = themesURL.appendingPathComponent(finalName).appendingPathExtension("cetheme")

            // Check for existing display names in themes
            while themes.contains(where: { theme != $0 && $0.displayName == finalName }) {
                finalName = "\(newName) \(iterator)"
                finalURL = themesURL.appendingPathComponent(finalName).appendingPathExtension("cetheme")
                iterator += 1
            }

            try filemanager.moveItem(at: oldURL, to: finalURL)

            try self.loadThemes()

            if let index = themes.firstIndex(where: { $0.fileURL == finalURL }) {
                themes[index].displayName = finalName
                themes[index].fileURL = finalURL
                themes[index].name = finalName.lowercased().replacingOccurrences(of: " ", with: "-")
            }

        } catch {
            print("Error renaming theme: \(error.localizedDescription)")
        }
    }

    func duplicate(_ url: URL) {
        do {
            // Construct the destination file URL
            var destinationFileURL = self.themesURL.appendingPathComponent(url.lastPathComponent)

            // Extract the base filename and extension
            let fileExtension = destinationFileURL.pathExtension

            var fileName = destinationFileURL.deletingPathExtension().lastPathComponent
            var newFileName = fileName

            // Check if the file already exists
            var iterator = 1

            let isBundled = url.absoluteString.hasPrefix(bundledThemesURL?.absoluteString ?? "")
            let isImporting =
                !url.absoluteString.hasPrefix(bundledThemesURL?.absoluteString ?? "")
                && !url.absoluteString.hasPrefix(themesURL.absoluteString)

            if isBundled {
                newFileName = "\(fileName) \(iterator)"
                destinationFileURL = self.themesURL
                    .appendingPathComponent(newFileName)
                    .appendingPathExtension(fileExtension)
            }

            while FileManager.default.fileExists(atPath: destinationFileURL.path) {
                fileName = destinationFileURL.deletingPathExtension().lastPathComponent

                // Remove any existing iterator
                if let range = fileName.range(of: " \\d+$", options: .regularExpression) {
                    fileName = String(fileName[..<range.lowerBound])
                }

                // Generate a new filename with an iterator
                newFileName = "\(fileName) \(iterator)"
                destinationFileURL = self.themesURL
                    .appendingPathComponent(newFileName)
                    .appendingPathExtension(fileExtension)

                iterator += 1
            }

            // Copy the file from selected URL to the destination
            try FileManager.default.copyItem(at: url, to: destinationFileURL)

            try self.loadThemes()

            if var index = self.themes.firstIndex(where: { $0.fileURL == destinationFileURL }) {
                self.themes[index].displayName = newFileName
                self.themes[index].name = newFileName.lowercased().replacingOccurrences(of: " ", with: "-")
                if isImporting != true {
                    self.themes[index].author = NSFullUserName()
                }
                self.selectedTheme = self.themes[index]
                self.detailsTheme = self.themes[index]
            }
        } catch {
            print("Error adding theme: \(error.localizedDescription)")
        }
    }

    /// Save theme to file
    func save(_ theme: Theme) {
        do {
            if let fileURL = theme.fileURL {
                let data = try JSONEncoder().encode(theme)
                let json = try JSONSerialization.jsonObject(with: data)
                let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
                try prettyJSON.write(to: fileURL, options: .atomic)
            }
        } catch {
            print("Error saving theme: \(error.localizedDescription)")
        }
    }
}
