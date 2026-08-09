//
//  Settings.swift
//  CodeEditModules/Settings
//
//  Created by Lukas Pistrol on 01.04.22.
//

import Foundation
import SwiftUI
import Combine

/// The Preferences View Model. Accessible via the singleton "``SettingsModel/shared``".
///
/// **Usage:**
/// ```swift
/// @StateObject
/// private var prefs: SettingsModel = .shared
/// ```
public final class Settings: ObservableObject {

    /// The publicly available singleton instance of ``SettingsModel``
    nonisolated(unsafe) public static let shared: Settings = .init()

    private var storeTask: AnyCancellable!
    private var revisionTask: AnyCancellable!

    private init() {
        self.preferences = .init()
        self.preferences = loadSettings()

        self.storeTask = self.$preferences.throttle(for: 2, scheduler: RunLoop.main, latest: true).sink {
            try? self.savePreferences($0)
        }
        // Bumped on the `willSet` emission, i.e. before SwiftUI runs the update pass that the same
        // change schedules, so a body evaluated for this change already sees the new revision.
        self.revisionTask = self.$preferences.dropFirst().sink { [weak self] _ in
            self?.revision &+= 1
        }
    }

    public static subscript<T>(_ path: WritableKeyPath<SettingsData, T>, suite: Settings = .shared) -> T {
        get {
            suite.preferences[keyPath: path]
        }
        set {
            suite.preferences[keyPath: path] = newValue
        }
    }

    /// Published instance of the ``Settings`` model.
    ///
    /// Changes are saved automatically.
    @Published public var preferences: SettingsData

    /// A counter incremented once per change to ``preferences``.
    ///
    /// This is the settings seam's **invalidation signal**. Views reach settings through
    /// ``SettingsValue``, whose only environment dependency would otherwise be
    /// ``EnvironmentValues/settingsAccessor`` — an existential holding a stateless store that never
    /// compares unequal to itself. Re-rendering on a settings change would then rest on SwiftUI
    /// treating a rewritten non-`Equatable` existential as a change, which is unspecified.
    /// An `Int` is `Equatable`, so an injector publishing it into
    /// ``EnvironmentValues/settingsRevision`` makes the invalidation explicit and precise: it
    /// changes exactly when settings change, and never otherwise.
    ///
    /// Deliberately not derived from `SettingsData` itself — the seam types must not name the
    /// app-wide aggregate.
    @Published public private(set) var revision: Int = 0

    /// Load and construct ``Settings`` model from
    /// `~/Library/Application Support/CodeEdit/settings.json`
    private func loadSettings() -> SettingsData {
        if !filemanager.fileExists(atPath: settingsURL.path) {
            try? filemanager.createDirectory(at: baseURL, withIntermediateDirectories: false)
            return .init()
        }

        guard let json = try? Data(contentsOf: settingsURL),
              let prefs = try? JSONDecoder().decode(SettingsData.self, from: json)
        else {
            return .init()
        }
        return prefs
    }

    /// Save``Settings`` model to
    /// `~/Library/Application Support/CodeEdit/settings.json`
    private func savePreferences(_ data: SettingsData) throws {
        let data = try JSONEncoder().encode(data)
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try prettyJSON.write(to: settingsURL, options: .atomic)
    }

    /// Default instance of the `FileManager`
    private let filemanager = FileManager.default

    /// The base URL of settings.
    ///
    /// Points to `~/Library/Application Support/CodeEdit/`
    public var baseURL: URL {
        filemanager
            .homeDirectoryForCurrentUser
            .appending(path: "Library/Application Support/CodeEdit", directoryHint: .isDirectory)
    }

    /// The URL of the `settings.json` settings file.
    ///
    /// Points to `~/Library/Application Support/CodeEdit/settings.json`
    private var settingsURL: URL {
        baseURL
            .appending(path: "settings")
            .appendingPathExtension("json")
    }
}
