//
//  File.swift
//  
//
//  Created by Lukas Pistrol on 01.04.22.
//

import Foundation
import SwiftUI

public class AppPreferencesModel: ObservableObject {

    public static let shared: AppPreferencesModel = .init()

    private init() {
        self.preferences = loadPreferences()
    }

    @Published
    public var preferences: AppPreferences! {
        didSet {
            try? savePreferences()
            objectWillChange.send()
        }
    }

    private func loadPreferences() -> AppPreferences {
        if !filemanager.fileExists(atPath: baseURL.path) {
            return .init()
        }

        guard let json = try? Data(contentsOf: baseURL),
              let prefs = try? JSONDecoder().decode(AppPreferences.self, from: json)
        else {
            return .init()
        }
        return prefs
    }

    private func savePreferences() throws {
        let data = try JSONEncoder().encode(preferences)
        let json = try JSONSerialization.jsonObject(with: data)
        let prettyJSON = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        try prettyJSON.write(to: baseURL, options: .atomic)
    }

    public let filemanager = FileManager.default
    public var baseURL: URL {
        return filemanager
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".codeedit", isDirectory: true)
            .appendingPathComponent("preferences")
            .appendingPathExtension("json")
    }
}
