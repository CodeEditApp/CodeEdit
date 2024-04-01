//
//  CEWorkspaceSettings.swift
//  CodeEdit
//
//  Created by Axel Martinez on 27/3/24.
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
final class CEWorkspaceSettings: ObservableObject {
	/// The publicly available singleton instance of ``CEWorkspaceSettingsModel``
	static let shared: CEWorkspaceSettings = .init()

	private var storeTask: AnyCancellable!

	private init() {
		self.preferences = .init()
		self.preferences = loadSettings()

		self.storeTask = self.$preferences.throttle(for: 2, scheduler: RunLoop.main, latest: true).sink {
			try? self.savePreferences($0)
		}
	}

	static subscript<T>(_ path: WritableKeyPath<SettingsData, T>, suite: Settings = .shared) -> T {
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
	@Published var preferences: CEWorkspaceSettingsData

	/// Load and construct ``Settings`` model from
	/// `~/Library/Application Support/CodeEdit/settings.json`
	private func loadSettings() -> CEWorkspaceSettingsData {
		if !filemanager.fileExists(atPath: settingsURL.path) {
			try? filemanager.createDirectory(at: baseURL, withIntermediateDirectories: false)
			return .init()
		}

		guard let json = try? Data(contentsOf: settingsURL),
			  let prefs = try? JSONDecoder().decode(CEWorkspaceSettingsData.self, from: json)
		else {
			return .init()
		}
		return prefs
	}

	/// Save``Settings`` model to
	/// `~/Library/Application Support/CodeEdit/settings.json`
	private func savePreferences(_ data: CEWorkspaceSettingsData) throws {
		print("Saving...")
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
