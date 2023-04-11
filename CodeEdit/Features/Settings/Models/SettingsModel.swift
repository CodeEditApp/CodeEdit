//
//  SettingsModel.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 01.04.22.
//

import Foundation
import SwiftUI

/// The Preferences View Model. Accessible via the singleton "``SettingsModel/shared``".
///
/// **Usage:**
/// ```swift
/// @StateObject
/// private var prefs: SettingsModel = .shared
/// ```
final class SettingsModel: ObservableObject {

    /// The publicly available singleton instance of ``SettingsModel``
    static let shared: SettingsModel = .init()

    private init() {
        self.preferences = .init()
        self.preferences = loadSettings()
    }

    /// Published instance of the ``Settings`` model.
    ///
    /// Changes are saved automatically.
    @Published
    var preferences: Settings {
        didSet {
            try? savePreferences()
        }
    }

    /// Load and construct ``Settings`` model from
    /// `~/Library/Application Support/CodeEdit/settings.json`
    private func loadSettings() -> Settings {
        if !filemanager.fileExists(atPath: settingsURL.path) {
            try? filemanager.createDirectory(at: baseURL, withIntermediateDirectories: false)
            return .init()
        }

        guard let json = try? Data(contentsOf: settingsURL),
              let prefs = try? JSONDecoder().decode(Settings.self, from: json)
        else {
            return .init()
        }
        return prefs
    }

    /// Save``Settings`` model to
    /// `~/Library/Application Support/CodeEdit/settings.json`
    private func savePreferences() throws {
        let data = try JSONEncoder().encode(preferences)
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try prettyJSON.write(to: settingsURL, options: .atomic)
    }

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base URL of settings.
    ///
    /// Points to `~/Library/Application Support/CodeEdit/`
    internal var baseURL: URL {
        filemanager
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/CodeEdit", isDirectory: true)
    }

    /// The URL of the `settings.json` settings file.
    ///
    /// Points to `~/Library/Application Support/CodeEdit/settings.json`
    private var settingsURL: URL {
        baseURL
            .appendingPathComponent("settings")
            .appendingPathExtension("json")
    }
}
