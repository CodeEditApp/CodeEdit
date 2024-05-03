//
//  CEWorkspaceSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI
import Combine

/// The CodeEdit workspace settings model.
final class CEWorkspaceSettings: ObservableObject {
    @ObservedObject private var workspace: WorkspaceDocument
    @Published public var preferences: CEWorkspaceSettingsData = .init()

    private var storeTask: AnyCancellable!
    private let fileManager = FileManager.default

    private var folderURL: URL? {
        guard let workspaceURL = workspace.fileURL else {
            return nil
        }

        return workspaceURL
            .appendingPathComponent(".codeedit", isDirectory: true)
    }

    private var settingsURL: URL? {
        folderURL?
            .appendingPathComponent("settings")
            .appendingPathExtension("json")
    }

    init(workspaceDocument: WorkspaceDocument) {
        self.workspace = workspaceDocument

        loadSettings()

        self.storeTask = self.$preferences.throttle(for: 2.0, scheduler: RunLoop.main, latest: true).sink {
            try? self.savePreferences($0)
        }
    }

    /// Load and construct ``CEWorkspaceSettings`` model from `.codeedit/settings.json`
    private func loadSettings() {
        if let settingsURL = settingsURL {
            if fileManager.fileExists(atPath: settingsURL.path) {
                guard let json = try? Data(contentsOf: settingsURL),
                      let prefs = try? JSONDecoder().decode(CEWorkspaceSettingsData.self, from: json)
                else { return }
                self.preferences = prefs
            }
        }
    }

    /// Save``CEWorkspaceSettings`` model to `.codeedit/settings.json`
    private func savePreferences(_ data: CEWorkspaceSettingsData) throws {
        // If the user doesn't have any settings to save, don't save them.
        guard !data.isEmpty() else { return }

        guard let folderURL, let settingsURL else { return }

        if !fileManager.fileExists(atPath: folderURL.path()) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }

        let data = try JSONEncoder().encode(data)
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try prettyJSON.write(to: settingsURL, options: .atomic)
    }
}
