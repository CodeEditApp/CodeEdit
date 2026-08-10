//
//  SettingsLocation.swift
//  CodeEdit
//
//  Created by Matthijs Eikelenboom on 10/08/26.
//

import Foundation

/// Where CodeEdit's user-editable configuration lives on disk.
///
/// Namespaced constants, not a service: a filesystem path has no state, no lifetime and nothing to
/// inject. It was previously reachable only through `Settings.shared.baseURL`, which made every
/// consumer of the *path* a consumer of the *singleton*. Splitting it out is what let that singleton
/// be deleted without inventing an injection channel for a constant.
public enum SettingsLocation {
    /// `~/Library/Application Support/CodeEdit/`
    public static var baseURL: URL {
        FileManager.default
            .homeDirectoryForCurrentUser
            .appending(path: "Library/Application Support/CodeEdit", directoryHint: .isDirectory)
    }

    /// `~/Library/Application Support/CodeEdit/settings.json`
    public static var settingsFileURL: URL {
        baseURL
            .appending(path: "settings")
            .appendingPathExtension("json")
    }
}
