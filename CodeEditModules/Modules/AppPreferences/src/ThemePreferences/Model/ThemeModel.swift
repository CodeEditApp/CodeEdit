//
//  ThemeModel.swift
//  
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
public class ThemeModel: ObservableObject {

    public static let shared: ThemeModel = .init()

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
    var selectedTab: Int = 2

    /// An array of loaded ``Theme``.
    @Published
    public var themes: [Theme] = [] {
        didSet {
            // TODO: Don't overwrite themes
            // Instead save changed values to `preferences.json`
            // as overrides
            saveThemes()
            objectWillChange.send()
        }
    }

    /// The currently selected ``Theme``.
    @Published
    public var selectedTheme: Theme? {
        didSet {
            AppPreferencesModel.shared.preferences.theme.selectedTheme = selectedTheme?.name
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
    private func load(from url: URL) throws -> Theme {
        // get the data from the provided file
        let json = try Data(contentsOf: url)
        // decode the json into ``Theme``
        let theme = try JSONDecoder().decode(Theme.self, from: json)
        return theme
    }

    /// Loads all available themes from `~/.codeedit/themes/`
    ///
    /// If no themes are available, it will create a default theme and save
    /// it to the location mentioned above.
    public func loadThemes() throws {
        themes.removeAll()
        let url = baseURL.appendingPathComponent("themes")

        var isDir: ObjCBool = false

        // check if a themes directory exists, otherwise create one
        if !filemanager.fileExists(atPath: url.path, isDirectory: &isDir) {
            try filemanager.createDirectory(at: url, withIntermediateDirectories: true)
        }

        // get all filenames in themes folder that end with `.json`
        let content = try filemanager.contentsOfDirectory(atPath: url.path).filter { $0.contains(".json") }

        // if the folder does not contain any themes create a default bundled theme and return
        if content.isEmpty {
            guard let defaultUrl = Bundle.main.url(forResource: "default-dark", withExtension: "json") else {
                return
            }
            self.themes.append(try load(from: defaultUrl))
            return
        }

        let prefs = AppPreferencesModel.shared.preferences
        // load each theme from disk
        try content.forEach { file in
            let fileURL = url.appendingPathComponent(file)
            var theme = try load(from: fileURL)
            guard let terminalColors = try theme.terminal.allProperties() as? [String: Theme.Attributes],
                  let editorColors = try theme.editor.allProperties() as? [String: Theme.Attributes]
            else {
                print("error")
                throw NSError()
            }
            if let overrides = prefs?.theme.overrides[theme.name]?["terminal"] {
                terminalColors.forEach { (key, _) in
                    if let attributes = overrides[key] {
                        theme.terminal[key] = attributes
                    }
                }
            }
            if let overrides = prefs?.theme.overrides[theme.name]?["editor"] {
                editorColors.forEach { (key, _) in
                    if let attributes = overrides[key] {
                        theme.editor[key] = attributes
                    }
                }
            }
            self.themes.append(theme)
            self.selectedTheme = self.themes.first { $0.name == prefs?.theme.selectedTheme } ?? self.themes.first
            print("loaded themes")
        }
    }

    public func reset(_ theme: Theme) {
        AppPreferencesModel.shared.preferences.theme.overrides[theme.name] = [:]
        do {
            try self.loadThemes()
        } catch {
            print(error)
        }
    }

    public func delete(_ theme: Theme) {
        let url = baseURL
            .appendingPathComponent("themes")
            .appendingPathComponent(theme.name)
            .appendingPathExtension("json")
        do {
            try filemanager.removeItem(at: url)
            try self.loadThemes()
        } catch {
            print(error)
        }
    }

    private func saveThemes() {
        let url = baseURL.appendingPathComponent("themes")
        themes.forEach { theme in
            do {
                let originalUrl = url.appendingPathComponent(theme.name).appendingPathExtension("json")
                let originalData = try Data(contentsOf: originalUrl)
                let originalTheme = try JSONDecoder().decode(Theme.self, from: originalData)
                guard let terminalColors = try theme.terminal.allProperties() as? [String: Theme.Attributes],
                      let editorColors = try theme.editor.allProperties() as? [String: Theme.Attributes],
                      let oTermColors = try originalTheme.terminal.allProperties() as? [String: Theme.Attributes],
                      let oEditColors = try originalTheme.editor.allProperties() as? [String: Theme.Attributes]
                else {
                    throw NSError()
                }
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

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base folder url `~/.codeedit/`
    private var baseURL: URL {
        filemanager.homeDirectoryForCurrentUser.appendingPathComponent(".codeedit")
    }
}

extension Theme: Loopable {}

extension Theme.EditorColors: Loopable {}
extension Theme.TerminalColors: Loopable {}
extension Theme.Attributes: Loopable {}

protocol Loopable {
    func allProperties() throws -> [String: Any]
}

extension Loopable {
    func allProperties() throws -> [String: Any] {
        var result: [String: Any] = [:]

        let mirror = Mirror(reflecting: self)

        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            throw NSError()
        }

        for (property, value) in mirror.children {
            guard let property = property else {
                continue
            }

            result[property] = value
        }

        return result
    }
}
