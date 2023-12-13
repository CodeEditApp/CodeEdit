//
//  SearchSettingsModel.swift
//  CodeEdit
//
//  Created by Esteban on 12/10/23.
//

import SwiftUI

/// The Search Settings View Model. Accessible via the singleton "``SearchSettings/shared``".
///
/// **Usage:**
/// ```swift
/// @StateObject
/// private var searchSettigs: SearchSettingsModel = .shared
/// ```
final class SearchSettingsModel: ObservableObject {
    static let shared: SearchSettingsModel = .init()

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base folder url `~/Library/Application Support/CodeEdit/`
    private var baseURL: URL {
        filemanager.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/CodeEdit")
    }

    /// The URL of the `search` folder
    internal var searchURL: URL {
        baseURL.appendingPathComponent("search", isDirectory: true)
    }

    /// The URL of the `Extensions` folder
    internal var extensionsURL: URL {
        baseURL.appendingPathComponent("Extensions", isDirectory: true)
    }

    /// The URL of the `settings.json` file
    internal var settingsURL: URL {
        baseURL.appendingPathComponent("settings.json", isDirectory: true)
    }

    /// The currently existent Search Ignore Glob Patterns.
    @Published var ignoreGlobPatterns: [String] {
        didSet {
            DispatchQueue.main.async {
                Settings[\.search].ignoreGlobPatterns = self.ignoreGlobPatterns
            }
        }
    }

    private init() {
        self.ignoreGlobPatterns = []
    }
}
