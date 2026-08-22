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

    @AppSettings(\.theme)
    var settings

    /// Default instance of the `FileManager`
    let filemanager = FileManager.default

    /// The base folder url `~/Library/Application Support/CodeEdit/`
    private var baseURL: URL {
        filemanager.homeDirectoryForCurrentUser.appending(path: "Library/Application Support/CodeEdit")
    }

    var bundledThemesURL: URL? {
        Bundle.main.resourceURL?.appending(path: "DefaultThemes", directoryHint: .isDirectory) ?? nil
    }

    /// The URL of the `Themes` folder
    internal var themesURL: URL {
        baseURL.appending(path: "Themes", directoryHint: .isDirectory)
    }

    /// The URL of the `Extensions` folder
    internal var extensionsURL: URL {
        baseURL.appending(path: "Extensions", directoryHint: .isDirectory)
    }

    /// The URL of the `settings.json` file
    internal var settingsURL: URL {
        baseURL.appending(path: "settings.json", directoryHint: .isDirectory)
    }

    /// System color scheme
    @Published var colorScheme: ColorScheme = .light {
        didSet {
            refreshGeneratedTheme()
        }
    }

    private var systemColorsObserver: NSObjectProtocol?

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

    @Published var detailsIsPresented: Bool = false

    @Published var isAdding: Bool = false

    @Published var detailsTheme: Theme?

    /// An array of loaded ``Theme``.
    @Published var themes: [Theme] = []

    /// A transient editor theme derived from the current system accent color.
    @Published private(set) var generatedTheme: Theme?

    /// The currently selected ``Theme``.
    @Published var selectedTheme: Theme? {
        didSet {
            DispatchQueue.main.async {
                Settings[\.theme].selectedTheme = self.selectedTheme?.name
            }
        }
    }

    @Published var previousTheme: Theme?

    /// The theme currently used by the source editor.
    var effectiveTheme: Theme? {
        generatedTheme ?? selectedTheme
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
        colorScheme = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            ? .dark
            : .light
        do {
            try loadThemes()
        } catch {
            print(error)
        }

        systemColorsObserver = NotificationCenter.default.addObserver(
            forName: NSColor.systemColorsDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshGeneratedTheme()
        }
        refreshGeneratedTheme()
    }

    deinit {
        if let systemColorsObserver {
            NotificationCenter.default.removeObserver(systemColorsObserver)
        }
    }

    /// Rebuilds the transient generated theme, or removes it when generation is disabled.
    func refreshGeneratedTheme() {
        guard settings.automaticallyGenerateTheme else {
            generatedTheme = nil
            return
        }

        let baseTheme: Theme? = if settings.matchAppearance {
            colorScheme == .dark ? selectedDarkTheme : selectedLightTheme
        } else {
            selectedTheme
        }

        guard let baseTheme else {
            generatedTheme = nil
            return
        }

        generatedTheme = GeneratedThemeGenerator.generate(
            from: baseTheme,
            seedColor: GeneratedThemeGenerator.systemAccentColor(for: baseTheme.appearance),
            strategy: settings.generatedThemeStrategy
        )
    }

    /// Synchronizes the model with the active appearance and selects the matching manual theme when requested.
    func syncAppearance(with colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        guard settings.matchAppearance else { return }
        selectedTheme = colorScheme == .dark ? selectedDarkTheme : selectedLightTheme
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

    /// Initialize to the app's current appearance.
    var selectedAppearance: ThemeSettingsAppearances {
        NSApp.effectiveAppearance.name == .darkAqua ? .dark : .light
    }

    enum ThemeSettingsAppearances: String, CaseIterable {
        case light = "Light Appearance"
        case dark = "Dark Appearance"
    }

    func getThemeActive(_ theme: Theme) -> Bool {
        return generatedTheme == nil && selectedTheme == theme
    }

    /// Activates the current theme, setting ``selectedTheme`` and ``selectedLightTheme``/``selectedDarkTheme`` as
    /// necessary.
    /// - Parameter theme: The theme to activate.
    func activateTheme(_ theme: Theme) {
        if settings.automaticallyGenerateTheme {
            settings.automaticallyGenerateTheme = false
            generatedTheme = nil
        }
        selectedTheme = theme
        if colorScheme == .light {
            selectedLightTheme = theme
        }
        if colorScheme == .dark {
            selectedDarkTheme = theme
        }
    }

    func exportTheme(_ theme: Theme) {
        guard let themeFileURL = theme.fileURL else {
            print("Theme file URL not found.")
            return
        }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType(filenameExtension: "cetheme")!]
        savePanel.nameFieldStringValue = theme.displayName
        savePanel.prompt = "Export"
        savePanel.canCreateDirectories = true

        savePanel.begin { response in
            if response == .OK, let destinationURL = savePanel.url {
                do {
                    try FileManager.default.copyItem(at: themeFileURL, to: destinationURL)
                    print("Theme exported successfully to \(destinationURL.path)")
                } catch {
                    print("Failed to export theme: \(error.localizedDescription)")
                }
            }
        }
    }

    func exportAllCustomThemes() {
            let openPanel = NSOpenPanel()
            openPanel.prompt = "Export"
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.allowsMultipleSelection = false

            openPanel.begin { result in
                if result == .OK, let exportDirectory = openPanel.url {
                    let customThemes = self.themes.filter { !$0.isBundled }

                    for theme in customThemes {
                        guard let sourceURL = theme.fileURL else { continue }

                        let destinationURL = exportDirectory.appending(path: "\(theme.displayName).cetheme")

                        do {
                            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                            print("Exported \(theme.displayName) to \(destinationURL.path)")
                        } catch {
                            print("Failed to export \(theme.displayName): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
}
