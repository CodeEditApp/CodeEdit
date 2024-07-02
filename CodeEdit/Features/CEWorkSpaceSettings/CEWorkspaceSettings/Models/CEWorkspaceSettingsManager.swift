//
//  CEWorkspaceSettingsManager.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI
import Combine

/// The CodeEdit workspace settings model.
final class CEWorkspaceSettingsManager: ObservableObject {
    @ObservedObject private var workspace: WorkspaceDocument
    @Published public var settings: CEWorkspaceSettings = .init()

    private var storeTask = Set<AnyCancellable>()
    private let fileManager = FileManager.default

    var workspaceSettingsFolderURL: URL? {
        guard let workspaceURL = workspace.fileURL else {
            return nil
        }

        return workspaceURL
            .appendingPathComponent(".codeedit", isDirectory: true)
    }

    private var settingsURL: URL? {
        workspaceSettingsFolderURL?
            .appendingPathComponent("settings")
            .appendingPathExtension("json")
    }

    init(workspaceDocument: WorkspaceDocument) {
        self.workspace = workspaceDocument

        loadSettings()

        self.$settings
            .receive(on: DispatchQueue.main)
            .throttle(for: 2.0, scheduler: RunLoop.main, latest: true)
            .sink { _ in
                try? self.savePreferences()
            }
            .store(in: &storeTask)
    }

    /// Load and construct ``CEWorkspaceSettingsManager`` model from `.codeedit/settings.json`
    private func loadSettings() {
        if let settingsURL = settingsURL {
            if fileManager.fileExists(atPath: settingsURL.path) {
                guard let json = try? Data(contentsOf: settingsURL),
                      let prefs = try? JSONDecoder().decode(CEWorkspaceSettings.self, from: json)
                else { return }
                self.settings = prefs
            }
        }
    }

    /// Save``CEWorkspaceSettingsManager`` model to `.codeedit/settings.json`
    func savePreferences() throws {
        // If the user doesn't have any settings to save, don't save them.
        guard !settings.isEmpty() else { return }

        guard let workspaceSettingsFolderURL, let settingsURL else { return }

        if !fileManager.fileExists(atPath: workspaceSettingsFolderURL.path()) {
            try fileManager.createDirectory(at: workspaceSettingsFolderURL, withIntermediateDirectories: true)
        }

        let data = try JSONEncoder().encode(settings)
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try prettyJSON.write(to: settingsURL, options: .atomic)
    }
}
