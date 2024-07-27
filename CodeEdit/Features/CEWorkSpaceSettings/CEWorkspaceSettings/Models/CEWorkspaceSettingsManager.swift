//
//  CEWorkspaceSettingsManager.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
//

import SwiftUI
import Combine

/// The CodeEdit workspace settings model.
final class CEWorkspaceSettings: ObservableObject {
    @Published public var preferences: CEWorkspaceSettingsData = .init()

    private var storeTask: AnyCancellable?
    private let fileManager = FileManager.default

    private(set) var folderURL: URL?

    private var settingsURL: URL? {
        workspaceSettingsFolderURL?
            .appendingPathComponent("settings")
            .appendingPathExtension("json")
    }

    init(workspaceDocument: WorkspaceDocument) {
        folderURL = workspaceDocument.fileURL?.appendingPathComponent(".codeedit", isDirectory: true)
        loadSettings()

        self.$settings
            .receive(on: DispatchQueue.main)
            .throttle(for: 2.0, scheduler: RunLoop.main, latest: true)
            .sink { _ in
                try? self.savePreferences()
            }
            .store(in: &storeTask)
    }

    func cleanUp() {
        storeTask?.cancel()
        storeTask = nil
    }

    deinit {
        cleanUp()
    }

    /// Load and construct ``CEWorkspaceSettings`` model from `.codeedit/settings.json`
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
