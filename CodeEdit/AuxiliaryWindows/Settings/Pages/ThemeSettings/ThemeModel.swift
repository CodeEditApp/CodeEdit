//
//  ThemeModel.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 31.03.22.
//

import SwiftUI
import CodeEditCore
import CodeEditSettings
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

    /// The settings store, installed by `configure(settings:)`. `ThemeModel` is a pre-existing
    /// singleton that this change does not dismantle, so it cannot take the store through `init`.
    /// Left at `DefaultSettingsReader` it traps in debug, which is the point — a missing install is
    /// a wiring bug, not a runtime condition.
    private(set) var settingsAccessor: SettingsAccessing = DefaultSettingsReader()

    /// Read-modify-write of the whole `ThemeSettings` section, the granularity the store works in.
    func updateThemeSettings(_ mutate: (inout ThemeSettings) -> Void) {
        var section = settingsAccessor.value(ThemeSettings.self)
        mutate(&section)
        settingsAccessor.setValue(section)
    }

    /// The themes in effect, handed to the editor and the terminal as an `@EnvironmentObject`.
    ///
    /// Kept in sync from the `didSet` observers on ``selectedTheme`` and ``selectedDarkTheme``.
    /// Theme *management* state stays here; only the two themes in effect cross into rendering.
    let activeTheme = ActiveTheme()

    /// Default instance of the `FileManager`
    let filemanager = FileManager.default

    /// Handles all theme file I/O operations.
    let repository: ThemeRepository

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
    @Published var colorScheme: ColorScheme = .light

    /// Selected 'light' theme
    /// Used for auto-switching theme to match macOS system appearance
    @Published var selectedLightTheme: Theme? {
        didSet {
            DispatchQueue.main.async {
                self.updateThemeSettings { $0.selectedLightTheme = self.selectedLightTheme?.name ?? "Broken" }
            }
        }
    }

    /// Selected 'dark' theme
    /// Used for auto-switching theme to match macOS system appearance
    @Published var selectedDarkTheme: Theme? {
        didSet {
            // Synchronous on purpose: the async hop below defers a *settings write*. Deferring the
            // in-memory update too would delay the re-render this holder exists to deliver.
            publishActiveTheme()
            DispatchQueue.main.async {
                self.updateThemeSettings { $0.selectedDarkTheme = self.selectedDarkTheme?.name ?? "Broken" }
            }
        }
    }

    @Published var detailsIsPresented: Bool = false

    @Published var isAdding: Bool = false

    @Published var detailsTheme: Theme?

    /// An array of loaded ``Theme``.
    @Published var themes: [Theme] = []

    /// The currently selected ``Theme``.
    @Published var selectedTheme: Theme? {
        didSet {
            // Synchronous on purpose — see ``selectedDarkTheme``.
            publishActiveTheme()
            DispatchQueue.main.async {
                self.updateThemeSettings { $0.selectedTheme = self.selectedTheme?.name }
            }
        }
    }

    /// Pushes the current selection into ``activeTheme``, which publishes only on a real change.
    ///
    /// The `?? themes.first` carries over the fallback both former injection sites applied: if no
    /// theme matches the current appearance, any loaded theme beats none. It is deliberately not
    /// `themes.first!` — ``ActiveTheme/current`` is already optional, so the write site has no
    /// reason to trap. ``selectedDarkTheme`` gets no fallback because the old injection had none.
    private func publishActiveTheme() {
        activeTheme.update(current: selectedTheme ?? themes.first, dark: selectedDarkTheme)
    }

    @Published var previousTheme: Theme?

    /// Only themes where ``Theme/appearance`` == ``Theme/ThemeType/dark``
    var darkThemes: [Theme] {
        themes.filter { $0.appearance == .dark }
    }

    /// Only themes where ``Theme/appearance`` == ``Theme/ThemeType/light``
    var lightThemes: [Theme] {
        themes.filter { $0.appearance == .light }
    }

    private init() {
        let base = filemanager.homeDirectoryForCurrentUser.appending(path: "Library/Application Support/CodeEdit")
        self.repository = ThemeRepository(
            themesURL: base.appending(path: "Themes", directoryHint: .isDirectory),
            bundledThemesURL: Bundle.main.resourceURL?.appending(path: "DefaultThemes", directoryHint: .isDirectory)
        )
    }

    /// Installs the settings store and loads the themes from disk.
    ///
    /// Loading is deliberately *not* in `init`: it reads `theme` out of the store, and `init` runs
    /// the moment anything first touches `shared` — including the very line that would assign the
    /// store. The load would then read `DefaultSettingsReader` and select the wrong theme.
    func configure(settings: SettingsAccessing) {
        settingsAccessor = settings
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

    /// Initialize to the app's current appearance.
    var selectedAppearance: ThemeSettingsAppearances {
        NSApp.effectiveAppearance.name == .darkAqua ? .dark : .light
    }

    enum ThemeSettingsAppearances: String, CaseIterable {
        case light = "Light Appearance"
        case dark = "Dark Appearance"
    }

    func getThemeActive(_ theme: Theme) -> Bool {
        return selectedTheme == theme
    }

    /// Activates the current theme, setting ``selectedTheme`` and ``selectedLightTheme``/``selectedDarkTheme`` as
    /// necessary.
    /// - Parameter theme: The theme to activate.
    func activateTheme(_ theme: Theme) {
        selectedTheme = theme
        if colorScheme == .light {
            selectedLightTheme = theme
        }
        if colorScheme == .dark {
            selectedDarkTheme = theme
        }
    }

}
