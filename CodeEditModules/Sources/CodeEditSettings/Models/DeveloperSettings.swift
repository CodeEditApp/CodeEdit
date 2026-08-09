//
//  DeveloperSettings.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/15/24.
//

import Foundation

public struct DeveloperSettings: SettingsSection {

    /// The top-level key this section occupies in `settings.json`.
    public static let settingsKey = "developerSettings"

    /// A dictionary that stores a file type and a path to an LSP binary
    @CodableDefault<DefaultEmptyStringDictionary> public var lspBinaries: [String: String] = [:]

    /// Toggle for showing the internal development inspector
    @CodableDefault<DefaultFalse> public var showInternalDevelopmentInspector = false

    /// Default initializer
    public init() {}
}
