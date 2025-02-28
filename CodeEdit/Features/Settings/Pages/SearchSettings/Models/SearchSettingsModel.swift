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
    /// Reads settings file for Search Settings and updates the values in this model
    /// correspondingly
    private init() {
        let value = Settings[\.search].ignoreGlobPatterns
        self.ignoreGlobPatterns = value
    }

    static let shared: SearchSettingsModel = .init()

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base folder url `~/Library/Application Support/CodeEdit/`
    private var baseURL: URL {
        filemanager.homeDirectoryForCurrentUser.appending(path: "Library/Application Support/CodeEdit")
    }

    /// The URL of the `search` folder
    internal var searchURL: URL {
        baseURL.appending(path: "search", directoryHint: .isDirectory)
    }

    /// The URL of the `Extensions` folder
    internal var extensionsURL: URL {
        baseURL.appending(path: "Extensions", directoryHint: .isDirectory)
    }

    /// The URL of the `settings.json` file
    internal var settingsURL: URL {
        baseURL.appending(path: "settings.json", directoryHint: .isDirectory)
    }

    /// Selected patterns
    @Published var selection: Set<UUID> = []

    /// Stores the new values from the Search Settings Model into the settings.json whenever
    /// `ignoreGlobPatterns` is updated
    @Published var ignoreGlobPatterns: [GlobPattern] {
        didSet {
            DispatchQueue.main.async {
                Settings[\.search].ignoreGlobPatterns = self.ignoreGlobPatterns
            }
        }
    }

    func getPattern(for id: UUID) -> GlobPattern? {
        return ignoreGlobPatterns.first(where: { $0.id == id })
    }

    func addPattern() {
        ignoreGlobPatterns.append(GlobPattern(value: ""))
    }

    func removePatterns(_ selection: Set<UUID>? = nil) {
        let patternsToRemove = selection?.compactMap { getPattern(for: $0) } ?? []
        ignoreGlobPatterns.removeAll { patternsToRemove.contains($0) }
        self.selection.removeAll()
    }
}
