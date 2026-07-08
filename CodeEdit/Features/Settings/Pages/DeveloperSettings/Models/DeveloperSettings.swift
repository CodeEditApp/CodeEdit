//
//  DeveloperSettings.swift
//  CodeEdit
//
//  Created by Abe Malla on 5/15/24.
//

import Foundation

extension SettingsData {
    struct DeveloperSettings: Codable, Hashable {

        /// A dictionary that stores a file type and a path to an LSP binary
        @CodableDefault<DefaultEmptyStringDictionary> var lspBinaries: [String: String] = [:]

        /// Toggle for showing the internal development inspector
        @CodableDefault<DefaultFalse> var showInternalDevelopmentInspector = false

        /// Default initializer
        init() {}
    }
}
