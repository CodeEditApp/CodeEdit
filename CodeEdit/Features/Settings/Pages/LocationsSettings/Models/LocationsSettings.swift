//
//  LocationsSettings.swift
//  CodeEdit
//
//  Created by Raymond Vleeshouwer on 24/06/23.
//

import Foundation

extension SettingsData {

    struct LocationsSettings: Codable, Hashable {
        /// The URL of the `themes` folder
        var themesURL: URL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/CodeEdit")
            .appendingPathComponent("themes", isDirectory: true)

        /// The URL of the `Extensions` folder
        var extensionsURL: URL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/CodeEdit")
            .appendingPathComponent("Extensions", isDirectory: true)

        /// The URL of the `settings.json` file
        var settingsURL: URL = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/CodeEdit")
            .appendingPathComponent("settings.json", isDirectory: true)

        /// Default Initializer
        init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let baseURL: URL = FileManager.default.homeDirectoryForCurrentUser
            self.themesURL = try container.decodeIfPresent(
                URL.self,
                forKey: .themesURL
            ) ?? baseURL.appendingPathComponent("themes", isDirectory: true)
            self.extensionsURL = try container.decodeIfPresent(
                URL.self,
                forKey: .extensionsURL
            ) ?? baseURL.appendingPathComponent("Extensions", isDirectory: true)
            self.settingsURL = try container.decodeIfPresent(
                URL.self,
                forKey: .settingsURL
            ) ?? baseURL.appendingPathComponent("settings.json", isDirectory: true)
        }
    }
}
