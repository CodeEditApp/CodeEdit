//
//  AppPreferencesModel.swift
//  CodeEditModules/AppPreferences
//
//  Created by Lukas Pistrol on 01.04.22.
//

import Foundation
import SwiftUI

/// The Preferences View Model. Accessible via the singleton "``AppPreferencesModel/shared``".
///
/// **Usage:**
/// ```swift
/// @StateObject
/// private var prefs: AppPreferencesModel = .shared
/// ```
public final class AppPreferencesModel: ObservableObject {

    /// The publicly available singleton instance of ``AppPreferencesModel``
    public static let shared: AppPreferencesModel = .init()

    private init() {
        self.preferences = .init()
        self.preferences = loadPreferences()
    }

    /// Published instance of the ``AppPreferences`` model.
    ///
    /// Changes are saved automatically.
    @Published
    public var preferences: AppPreferences {
        didSet {
            try? savePreferences()
            objectWillChange.send()
        }
    }

    /// Load and construct ``AppPreferences`` model from
    /// `~/.codeedit/preferences.json`
    private func loadPreferences() -> AppPreferences {
        if !filemanager.fileExists(atPath: preferencesURL.path) {
            let codeEditURL = filemanager
                .homeDirectoryForCurrentUser
                .appendingPathComponent(".codeedit", isDirectory: true)
            try? filemanager.createDirectory(at: codeEditURL, withIntermediateDirectories: false)
            return .init()
        }

        guard let json = try? Data(contentsOf: preferencesURL),
              let prefs = try? JSONDecoder().decode(AppPreferences.self, from: json)
        else {
            return .init()
        }
        return prefs
    }

    /// Save``AppPreferences`` model to
    /// `~/.codeedit/preferences.json`
    private func savePreferences() throws {
        let data = try JSONEncoder().encode(preferences)
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try prettyJSON.write(to: preferencesURL, options: .atomic)
    }

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base URL of preferences.
    ///
    /// Points to `~/.codeedit/`
    internal var baseURL: URL {
        return filemanager
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".codeedit", isDirectory: true)
    }

    /// The URL of the `preferences.json` settings file.
    ///
    /// Points to `~/.codeedit/preferences.json`
    private var preferencesURL: URL {
        return baseURL
            .appendingPathComponent("preferences")
            .appendingPathExtension("json")
    }
}
