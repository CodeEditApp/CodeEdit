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
            try? saveThemes()
            objectWillChange.send()
        }
    }

    /// The currently selected ``Theme``.
    @Published
    public var selectedTheme: Theme?

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
            self.selectedTheme = themes.first
        } catch {
            print(error)
        }
    }

    /// Loads a theme from a given url and appends it to ``themes``.
    /// - Parameter url: The URL of the theme
    private func load(from url: URL) throws {
        // get the data from the provided file
        let json = try Data(contentsOf: url)
        // decode the json into ``Theme``
        let theme = try JSONDecoder().decode(Theme.self, from: json)
        self.themes.append(theme)
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
            try load(from: defaultUrl)
            return
        }

        // load each theme from disk
        try content.forEach { file in
            let fileURL = url.appendingPathComponent(file)
            try load(from: fileURL)
        }
    }

    private func saveThemes() throws {
        let url = baseURL.appendingPathComponent("themes")
        try themes.forEach { theme in
            let data = try JSONEncoder().encode(theme)
            let json = try JSONSerialization.jsonObject(with: data)
            let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            try prettyJSON.write(
                to: url.appendingPathComponent(theme.name).appendingPathExtension("json"),
                options: .atomic
            )
        }
    }

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base folder url `~/.codeedit/`
    private var baseURL: URL {
        filemanager.homeDirectoryForCurrentUser.appendingPathComponent(".codeedit")
    }
}
